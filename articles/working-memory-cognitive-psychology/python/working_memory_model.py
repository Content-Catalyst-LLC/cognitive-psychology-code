#!/usr/bin/env python3
"""
Working-memory research model.

This script can:
1. Generate synthetic working-memory trial data.
2. Estimate models for load effects, capacity, updating, interference,
   dual-task cost, cognitive load, response time, confidence, and interface support.
3. Save researcher-readable summaries to outputs/.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from typing import Dict

import numpy as np
import pandas as pd

try:
    import statsmodels.formula.api as smf
    import statsmodels.api as sm
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False


CONDITIONS = ["control", "high_load", "low_load", "interference", "dual_task", "chunking", "rehearsal_blocked", "ai_supported", "instructional_support"]
DOMAINS = ["general", "verbal", "visual", "spatial", "auditory", "language", "math", "learning", "interface", "ai"]
TASK_TYPES = ["simple_span", "complex_span", "operation_span", "reading_span", "spatial_span", "n_back", "serial_recall", "change_detection", "dual_task"]
MODALITIES = ["verbal", "visual", "spatial", "auditory", "multimodal", "semantic"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(n_participants: int = 320, trials_per_participant: int = 18, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"load_adj": 0.0, "interference": 0.0, "support": 0.0, "rt": 0.0},
        "high_load": {"load_adj": 2.5, "interference": 0.4, "support": 0.0, "rt": 0.12},
        "low_load": {"load_adj": -1.5, "interference": -0.3, "support": 0.0, "rt": -0.06},
        "interference": {"load_adj": 0.5, "interference": 3.0, "support": 0.0, "rt": 0.10},
        "dual_task": {"load_adj": 0.8, "interference": 1.8, "support": 0.0, "rt": 0.16},
        "chunking": {"load_adj": 0.0, "interference": -0.5, "support": 2.8, "rt": -0.03},
        "rehearsal_blocked": {"load_adj": 0.5, "interference": 1.5, "support": -1.8, "rt": 0.08},
        "ai_supported": {"load_adj": -0.3, "interference": -0.4, "support": 1.8, "rt": -0.10},
        "instructional_support": {"load_adj": -0.5, "interference": -0.6, "support": 2.4, "rt": -0.06},
    }

    task_processing = {
        "simple_span": 1.5,
        "complex_span": 4.5,
        "operation_span": 6.0,
        "reading_span": 5.5,
        "spatial_span": 2.8,
        "n_back": 6.4,
        "serial_recall": 3.5,
        "change_detection": 2.6,
        "dual_task": 7.2,
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        base_capacity = float(np.clip(rng.normal(4.2, 0.75), 2.0, 7.0))
        attentional_control_trait = float(np.clip(rng.normal(6.2, 1.0), 2.5, 9.5))
        processing_speed = rng.normal(0, 0.14)
        rehearsal_skill = float(np.clip(rng.normal(5.8, 1.0), 2.0, 9.5))

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            task_type = rng.choice(TASK_TYPES)
            modality = rng.choice(MODALITIES)
            ce = condition_effects[condition]

            raw_load = int(np.clip(round(rng.normal(4.5 + ce["load_adj"], 1.6)), 1, 10))
            load = raw_load
            serial_position = int(np.clip(round(rng.uniform(1, load + 0.999)), 1, max(load, 1)))
            distractor_level = float(np.clip(rng.normal(2.5 + ce["interference"] + 0.6 * (task_type in ["dual_task", "complex_span", "n_back"]), 1.2), 0, 10))
            interference = float(np.clip(rng.normal(2.5 + ce["interference"] + 0.5 * (modality in ["semantic", "verbal"]) + 0.3 * distractor_level, 1.0), 0, 10))
            attentional_control = float(np.clip(attentional_control_trait - 0.18 * distractor_level - 0.15 * interference + rng.normal(0, 0.5), 0, 10))
            updating_demand = float(np.clip(rng.normal(1.5 + 5.2 * (task_type == "n_back") + 3.5 * (task_type in ["complex_span", "dual_task"]) + 0.25 * load, 1.0), 0, 10))
            storage_demand = float(np.clip(rng.normal(load, 0.8), 0, 10))
            processing_demand = float(np.clip(rng.normal(task_processing[task_type] + 0.35 * ce["load_adj"], 1.0), 0, 10))
            chunking_support = float(np.clip(rng.normal(4.2 + ce["support"] + 1.2 * (domain in ["language", "math", "learning"]) - 0.25 * interference, 1.1), 0, 10))
            rehearsal_opportunity = float(np.clip(rng.normal(5.8 + 0.2 * rehearsal_skill - 3.2 * (condition == "rehearsal_blocked") - 0.25 * distractor_level, 1.0), 0, 10))
            learning_support = float(np.clip(rng.normal(3.5 + 2.8 * (condition == "instructional_support") + 1.4 * (condition == "ai_supported") + 0.35 * chunking_support, 1.1), 0, 10))
            interface_complexity = float(np.clip(rng.normal(3.0 + 2.6 * (domain in ["interface", "ai"]) + 0.35 * load + 0.2 * distractor_level - 0.25 * learning_support, 1.1), 0, 10))

            cognitive_load = float(np.clip(0.30 * storage_demand + 0.32 * processing_demand + 0.25 * updating_demand + 0.20 * interference + 0.20 * interface_complexity - 0.22 * chunking_support - 0.15 * learning_support + rng.normal(1.5, 0.6), 0, 10))
            capacity_estimate = float(np.clip(base_capacity + 0.14 * chunking_support + 0.08 * rehearsal_opportunity + 0.10 * attentional_control - 0.12 * interference - 0.08 * cognitive_load + rng.normal(0, 0.25), 1, 9))
            overload = max(0.0, load - capacity_estimate)
            overload_probability = float(np.clip(logistic(np.array([-1.6 + 0.70 * overload + 0.16 * cognitive_load + 0.10 * interference - 0.12 * attentional_control]))[0], 0, 1))

            accuracy_latent = (
                2.1
                + 0.48 * capacity_estimate
                + 0.18 * attentional_control
                + 0.12 * chunking_support
                + 0.10 * rehearsal_opportunity
                + 0.06 * learning_support
                - 0.48 * load
                - 0.26 * interference
                - 0.22 * updating_demand
                - 0.18 * processing_demand
                - 0.16 * cognitive_load
                - 0.35 * (condition == "dual_task")
                + rng.normal(0, 0.35)
            )
            accuracy = float(np.clip(logistic(np.array([accuracy_latent]))[0] + rng.normal(0, 0.04), 0, 1))
            correct = int(rng.random() < accuracy)

            span_score = float(np.clip(round(capacity_estimate + rng.normal(0, 0.9)), 0, 12))
            updating_score = float(np.clip(accuracy - 0.03 * updating_demand + 0.02 * attentional_control + rng.normal(0, 0.05), 0, 1))
            dual_task_cost = float(np.clip(0.03 + 0.04 * processing_demand + 0.04 * interference + 0.10 * (condition == "dual_task") - 0.02 * learning_support + rng.normal(0, 0.03), 0, 1))

            rt_ms = int(np.clip(np.exp(math.log(950) + ce["rt"] + 0.045 * load + 0.040 * updating_demand + 0.035 * processing_demand + 0.040 * interference + 0.045 * cognitive_load - 0.020 * attentional_control + processing_speed + rng.normal(0, 0.14)), 150, 60000))
            confidence = float(np.clip(0.38 + 0.46 * accuracy + 0.03 * attentional_control - 0.025 * overload - 0.020 * cognitive_load + rng.normal(0, 0.08), 0, 1))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "task_type": task_type,
                    "modality": modality,
                    "load": load,
                    "serial_position": serial_position,
                    "distractor_level": round(distractor_level, 3),
                    "interference": round(interference, 3),
                    "attentional_control": round(attentional_control, 3),
                    "updating_demand": round(updating_demand, 3),
                    "storage_demand": round(storage_demand, 3),
                    "processing_demand": round(processing_demand, 3),
                    "chunking_support": round(chunking_support, 3),
                    "rehearsal_opportunity": round(rehearsal_opportunity, 3),
                    "cognitive_load": round(cognitive_load, 3),
                    "span_score": round(span_score, 3),
                    "updating_score": round(updating_score, 4),
                    "capacity_estimate": round(capacity_estimate, 4),
                    "overload_probability": round(overload_probability, 4),
                    "dual_task_cost": round(dual_task_cost, 4),
                    "correct": correct,
                    "accuracy": round(accuracy, 4),
                    "response_time_ms": rt_ms,
                    "confidence": round(confidence, 4),
                    "learning_support": round(learning_support, 3),
                    "interface_complexity": round(interface_complexity, 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("correct", "size"),
            participants=("participant", "nunique"),
            mean_load=("load", "mean"),
            correct_rate=("correct", "mean"),
            mean_accuracy=("accuracy", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_span_score=("span_score", "mean"),
            mean_updating_score=("updating_score", "mean"),
            mean_capacity_estimate=("capacity_estimate", "mean"),
            mean_overload_probability=("overload_probability", "mean"),
            mean_dual_task_cost=("dual_task_cost", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_task = (
        df.groupby("task_type")
        .agg(
            n_trials=("correct", "size"),
            correct_rate=("correct", "mean"),
            mean_accuracy=("accuracy", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_span_score=("span_score", "mean"),
            mean_updating_score=("updating_score", "mean"),
            mean_capacity_estimate=("capacity_estimate", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_task.to_csv(outputs / "summary_by_task_type.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    acc_model = smf.glm(
        "correct ~ condition + task_type + modality + load + serial_position + distractor_level + "
        "interference + attentional_control + updating_demand + storage_demand + processing_demand + "
        "chunking_support + rehearsal_opportunity + cognitive_load + learning_support + interface_complexity",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Accuracy logistic model ===\n")
    model_text.append(str(acc_model.summary()))

    capacity_model = smf.ols(
        "capacity_estimate ~ condition + task_type + modality + load + interference + attentional_control + "
        "chunking_support + rehearsal_opportunity + cognitive_load + learning_support + interface_complexity",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Capacity-estimate model ===\n")
    model_text.append(str(capacity_model.summary()))

    updating_model = smf.ols(
        "updating_score ~ condition + task_type + modality + load + updating_demand + attentional_control + "
        "interference + cognitive_load + chunking_support + rehearsal_opportunity",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Updating-score model ===\n")
    model_text.append(str(updating_model.summary()))

    overload_model = smf.glm(
        "overload_probability ~ condition + task_type + load + capacity_estimate + interference + "
        "cognitive_load + attentional_control + learning_support + interface_complexity",
        data=df,
        family=sm.families.Gaussian(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Overload-probability model ===\n")
    model_text.append(str(overload_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["response_time_ms"])
    rt_model = smf.ols(
        "log_rt ~ condition + task_type + modality + load + updating_demand + processing_demand + "
        "interference + cognitive_load + attentional_control + correct + confidence",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    confidence_model = smf.ols(
        "confidence ~ condition + task_type + modality + accuracy + capacity_estimate + overload_probability + "
        "cognitive_load + attentional_control + interference + learning_support",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Confidence model ===\n")
    model_text.append(str(confidence_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    pd.DataFrame(
        {
            "term": acc_model.params.index,
            "accuracy_coef": acc_model.params.values,
            "accuracy_se": acc_model.bse.values,
        }
    ).to_csv(outputs / "accuracy_model_coefficients.csv", index=False)

    pd.DataFrame(
        {
            "term": capacity_model.params.index,
            "capacity_coef": capacity_model.params.values,
            "capacity_se": capacity_model.bse.values,
        }
    ).to_csv(outputs / "capacity_model_coefficients.csv", index=False)

    pd.DataFrame(
        {
            "term": rt_model.params.index,
            "response_time_coef": rt_model.params.values,
            "response_time_se": rt_model.bse.values,
        }
    ).to_csv(outputs / "response_time_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/working_memory_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=320)
    parser.add_argument("--trials", type=int, default=18)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = generate_dataset(n_participants=args.participants, trials_per_participant=args.trials, seed=args.seed)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default_input = Path("data/working_memory_trials.csv")
        if default_input.exists():
            df = pd.read_csv(default_input)
        else:
            df = generate_dataset(seed=args.seed)
            default_input.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(default_input, index=False)
            print(f"No input provided. Generated default dataset: {default_input}")

    summarize_data(df, args.outputs)
    run_models(df, args.outputs)
    print(f"Wrote summaries and model outputs to: {args.outputs}")


if __name__ == "__main__":
    main()
