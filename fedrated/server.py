"""
server.py  —  AgroSentinel AI  Federated Learning Server
=========================================================

Run standalone:
    python server.py

Or let simulate.py start it automatically.
"""

import os
import flwr as fl
import tensorflow as tf
import numpy as np
from typing import List, Tuple, Optional, Dict, Union
from flwr.common import Metrics, Parameters, Scalar

_HERE            = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH       = os.path.join(_HERE, "..", "models", "crop_model.h5")
GLOBAL_MODEL_OUT = os.path.join(_HERE, "..", "models", "crop_model_federated.h5")

NUM_ROUNDS      = 3
MIN_CLIENTS     = 3
SERVER_ADDRESS  = "0.0.0.0:8080"


def weighted_average(metrics: List[Tuple[int, Metrics]]) -> Metrics:
    """Aggregate accuracy from all nodes weighted by sample count."""
    total = sum(n for n, _ in metrics)
    if total == 0:
        return {}
    accs = [n * m.get("accuracy", 0) for n, m in metrics]
    return {"accuracy": sum(accs) / total}


def get_evaluate_fn(model: tf.keras.Model):
    """Server-side evaluation function after each aggregation round."""

    def evaluate(
        server_round: int,
        parameters: fl.common.NDArrays,
        config: Dict[str, Scalar],
    ) -> Optional[Tuple[float, Dict[str, Scalar]]]:
        # parameters is already NDArrays (list of numpy arrays) in Flower 1.33
        model.set_weights(parameters)
        print(f"\n   Round {server_round} — global weights aggregated from all nodes")
        return 0.0, {"round": server_round}

    return evaluate


def start_server():
    print("=" * 60)
    print("  AgroSentinel AI — Federated Learning Server")
    print("=" * 60)
    print(f"\n  Strategy      : FedAvg (Federated Averaging)")
    print(f"  Rounds        : {NUM_ROUNDS}")
    print(f"  Min clients   : {MIN_CLIENTS}")
    print(f"  Server addr   : {SERVER_ADDRESS}")
    print(f"\n  Privacy model : Farm images NEVER leave local devices")
    print(f"                  Only model weights are transmitted")
    print("\n  Waiting for farm nodes to connect...")
    print("-" * 60)

    print(f"\n  Loading base model: {MODEL_PATH}")
    model      = tf.keras.models.load_model(MODEL_PATH)
    init_weights = model.get_weights()

    strategy = fl.server.strategy.FedAvg(
        min_fit_clients=MIN_CLIENTS,
        min_evaluate_clients=MIN_CLIENTS,
        min_available_clients=MIN_CLIENTS,
        initial_parameters=fl.common.ndarrays_to_parameters(init_weights),
        fit_metrics_aggregation_fn=weighted_average,
        evaluate_metrics_aggregation_fn=weighted_average,
        evaluate_fn=get_evaluate_fn(model),
    )

    history = fl.server.start_server(
        server_address=SERVER_ADDRESS,
        config=fl.server.ServerConfig(num_rounds=NUM_ROUNDS),
        strategy=strategy,
    )

    # Save final federated model
    print("\n" + "=" * 60)
    print("  Federated training complete!")
    model.save(GLOBAL_MODEL_OUT)
    print(f"  Global model saved → {GLOBAL_MODEL_OUT}")
    print("=" * 60)

    return history


if __name__ == "__main__":
    start_server()