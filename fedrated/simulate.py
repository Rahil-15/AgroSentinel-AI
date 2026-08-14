"""
simulate.py  —  AgroSentinel AI  Federated Learning Simulation
===============================================================
Runs the complete federated learning simulation on ONE laptop.
Starts the server and all 3 farm node clients automatically
using Python multiprocessing — no multiple devices needed.

This is what you run for the college demo.

Run from the federated/ folder:
    python simulate.py

What you will see:
    - Server starts and waits for nodes
    - Node 1 (Corn farm) connects and trains locally
    - Node 2 (Rice farm) connects and trains locally
    - Node 3 (Potato+Tomato farm) connects and trains locally
    - Server aggregates weights using FedAvg
    - Repeat for NUM_ROUNDS rounds
    - Final global model saved to models/crop_model_federated.h5

    
"""

import os
import sys
import time
import multiprocessing as mp

_HERE = os.path.dirname(os.path.abspath(__file__))

# ── Config ────────────────────────────────────────────────────────────────────
NUM_ROUNDS    = 3
NUM_NODES     = 3
SERVER_WAIT   = 8      # seconds to wait for server to start before clients connect


def run_server():
    """Run the federated server in a separate process."""
    # Add federated folder to path
    sys.path.insert(0, _HERE)
    from server import start_server
    start_server()


def run_client(node_id: int):
    """Run one farm node client in a separate process."""
    sys.path.insert(0, _HERE)
    # Wait for server to fully start before connecting
    time.sleep(SERVER_WAIT + (node_id * 2))
    from client import start_client
    start_client(node_id)


def print_banner():
    print("\n")
    print("=" * 65)
    print("  █████╗  ██████╗ ██████╗  ██████╗")
    print("  ██╔══██╗██╔════╝ ██╔══██╗██╔═══██╗")
    print("  ███████║██║  ███╗██████╔╝██║   ██║")
    print("  ██╔══██║██║   ██║██╔══██╗██║   ██║")
    print("  ██║  ██║╚██████╔╝██║  ██║╚██████╔╝")
    print("  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝")
    print()
    print("  AgroSentinel AI — Federated Learning Simulation")
    print("=" * 65)
    print()
    print("  Simulating a privacy-preserving federated network")
    print("  across 3 virtual farm nodes on this single laptop.")
    print()
    print("  Node 1   Corn farm")
    print("  Node 2   Rice farm")
    print("  Node 3   Potato + Tomato farm")
    print()
    print("  Key principle: Raw crop images NEVER leave each node.")
    print("  Only model weights are shared with the central server.")
    print()
    print(f"  Rounds  : {NUM_ROUNDS}")
    print(f"  Nodes   : {NUM_NODES}")
    print(f"  Strategy: FedAvg (Federated Averaging)")
    print("=" * 65)
    print()


def simulate():
    print_banner()

    # ── Start server process ──────────────────────────────────────────────
    print("  Starting federated server...")
    server_process = mp.Process(target=run_server, name="FL-Server")
    server_process.start()
    print(f"     Server PID: {server_process.pid}")
    print(f"     Waiting {SERVER_WAIT}s for server to initialise...")
    time.sleep(SERVER_WAIT)

    # ── Start client processes ────────────────────────────────────────────
    client_processes = []
    for node_id in range(1, NUM_NODES + 1):
        print(f"\n  🌾 Starting Farm Node {node_id}...")
        p = mp.Process(
            target=run_client,
            args=(node_id,),
            name=f"FL-Node-{node_id}",
        )
        p.start()
        client_processes.append(p)
        print(f"     Node {node_id} PID: {p.pid}")
        time.sleep(1)   # stagger starts slightly

    print("\n" + "=" * 65)
    print("  All processes started. Federated training in progress...")
    print("  This will take several minutes. Do not close the terminal.")
    print("=" * 65 + "\n")

    # ── Wait for all clients to finish ────────────────────────────────────
    for p in client_processes:
        p.join()
        print(f"   {p.name} finished")

    # ── Wait for server to finish ─────────────────────────────────────────
    server_process.join(timeout=60)
    if server_process.is_alive():
        server_process.terminate()

    print("\n" + "=" * 65)
    print("   Federated Learning Simulation Complete!")
    print()
    print("  What just happened:")
    print("   _____________________________________________________")
    print("  │  3 farm nodes trained the crop disease model        │")
    print("  │  locally on their own crop data.                    │")
    print("  │                                                     │")
    print("  │  No raw leaf images were shared with the server.    │")
    print("  │  Only model weights were transmitted.               │")
    print("  │                                                     │")
    print("  │  The server combined all weights using FedAvg       │")
    print("  │  to produce one improved global model.              │")
    print("  |_____________________________________________________|")
    print()

    federated_model = os.path.join(
        _HERE, "..", "models", "crop_model_federated.h5"
    )
    if os.path.exists(federated_model):
        size_mb = os.path.getsize(federated_model) / (1024 * 1024)
        print(f"  Global model saved → {federated_model}")
        print(f"  File size          → {size_mb:.1f} MB")
    else:
        print("  Note: Check server logs above for model save status.")

    print("=" * 65 + "\n")


if __name__ == "__main__":
    # Windows requires this for multiprocessing
    mp.freeze_support()
    simulate()