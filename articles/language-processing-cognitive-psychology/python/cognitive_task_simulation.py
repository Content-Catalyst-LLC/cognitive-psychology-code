"""Synthetic cognitive psychology task simulation.

This script creates toy trial-level data for article examples.
It is educational only and not a clinical or diagnostic tool.
"""

from pathlib import Path
import csv
import random

random.seed(42)

rows = []
for trial in range(1, 121):
    load = random.choice([0.2, 0.5, 0.8])
    rt = 500 + load * 120 + random.gauss(0, 35)
    accuracy_probability = 0.95 - load * 0.45
    correct = int(random.random() < accuracy_probability)
    rows.append({
        "trial_index": trial,
        "cognitive_load_level": load,
        "reaction_time_ms": round(rt, 2),
        "correct": correct
    })

out = Path(__file__).resolve().parents[1] / "data" / "processed" / "synthetic_trials.csv"
out.parent.mkdir(parents=True, exist_ok=True)

with out.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} synthetic trials to {out}")
