"""
central_finetune_control.py  -  AgroSentinel AI  (centralised fine-tuning CONTROL)
=================================================================================
Question: is the federated model's gain (88.61% -> 93.32% on the test split) due
to FEDERATION, or just to extra class-balanced fine-tuning?

This script does the same fine-tuning WITHOUT federation:
  * starts from the same crop_model.h5
  * uses the SAME image subsets as the 3 federated nodes (it reuses client.py's
    loader: same seeds, at most 100 images per class)
  * same optimizer (Adam 1e-4), loss and batch size
  * same number of passes over the data: 3 rounds x 2 local epochs = 6 epochs
  * all data pooled in ONE place (no weight averaging, no nodes)

Run from the federated/ folder (next to client.py):
    python central_finetune_control.py

Output: models/crop_model_central_ft.h5   (your other model files are untouched)

Then evaluate it exactly like the others:
    cd ..\\models
    python evaluate_clean.py crop_model_central_ft.h5
"""

import os
import numpy as np
import tensorflow as tf

import client as C            # reuse the federated clients' data loader and settings

ROUNDS = 3                                  # federated rounds in the FL run
EPOCHS = ROUNDS * C.LOCAL_EPOCHS            # = 6 passes over the data


def main():
    tf.keras.utils.set_random_seed(0)
    name_to_idx, num_classes = C.load_global_labels()

    Xs, ys = [], []
    for node_id in sorted(C.NODE_CROP_MAP):
        X, y, n, used = C.load_node_data(node_id, "Train", name_to_idx, num_classes)
        if X is not None:
            Xs.append(X)
            ys.append(y)
    X = np.concatenate(Xs)
    y = np.concatenate(ys)
    del Xs, ys
    print(f"\n  Pooled training set: {len(X)} images, "
          f"{int((y.sum(axis=0) > 0).sum())} of {num_classes} classes")

    model = tf.keras.models.load_model(C.MODEL_PATH)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-4),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )

    print(f"  Fine-tuning for {EPOCHS} epochs (batch {C.BATCH_SIZE}) - no federation\n")
    model.fit(X, y, epochs=EPOCHS, batch_size=C.BATCH_SIZE, shuffle=True, verbose=1)

    out = os.path.join(C._HERE, "..", "models", "crop_model_central_ft.h5")
    model.save(out)
    print(f"\n  Saved -> {os.path.abspath(out)}")
    print("  Next:  cd ..\\models   then   python evaluate_clean.py crop_model_central_ft.h5")


if __name__ == "__main__":
    main()