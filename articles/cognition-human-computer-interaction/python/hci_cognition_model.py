#!/usr/bin/env python3
"""
Cognition in human-computer interaction.

This script can:
1. Generate synthetic HCI trial data.
2. Estimate models for task success, response time, error count,
   warning detection, trust, and cognitive load.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
HCI, human factors, usability, accessibility, and AI-interface research.
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


INTERFACE_CONDITIONS = [
    "baseline",
    "cluttered",
    "guided",
    "adaptive",
    "accessible",
    "ai_assisted",
]

TASKS = ["T01", "T02", "T03", "T04"]


def logistic(x: np.ndarray) -> np.ndarray:
    """Numerically stable logistic transform."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 180,
    trials_per_participant: int = 12,
    seed: int = 42,
) -> pd.DataFrame:
    """Generate synthetic HCI interaction trials."""

    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "baseline": {"percept": 4.5, "attention": 4.6, "wm": 4.6, "align": 6.5, "trust": 6.2, "auto": 3.5, "access": 2.4},
        "cluttered": {"percept": 8.0, "attention": 7.5, "wm": 6.2, "align": 4.5, "trust": 4.8, "auto": 4.2, "access": 4.8},
        "guided": {"percept": 3.7, "attention": 3.8, "wm": 4.1, "align": 8.0, "trust": 7.2, "auto": 4.2, "access": 1.8},
        "adaptive": {"percept": 4.2, "attention": 4.4, "wm": 5.0, "align": 7.4, "trust": 7.8, "auto": 7.2, "access": 2.2},
        "accessible": {"percept": 3.5, "attention": 3.7, "wm": 4.4, "align": 8.3, "trust": 7.5, "auto": 3.8, "access": 1.1},
        "ai_assisted": {"percept": 4.3, "attention": 5.0, "wm": 5.4, "align": 7.1, "trust": 7.6, "auto": 8.0, "access": 2.0},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        participant_skill = rng.normal(0, 0.45)
        participant_speed = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            interface_condition = rng.choice(INTERFACE_CONDITIONS)
            task_id = rng.choice(TASKS)
            cond = condition_effects[interface_condition]

            task_difficulty = np.clip(rng.normal({"T01": 3.5, "T02": 5.5, "T03": 7.0, "T04": 8.0}[task_id], 0.9), 0, 10)
            perceptual_load = np.clip(rng.normal(cond["percept"] + 0.10 * task_difficulty, 0.9), 0, 10)
            attentional_demand = np.clip(rng.normal(cond["attention"] + 0.12 * task_difficulty, 0.9), 0, 10)
            working_memory_load = np.clip(rng.normal(cond["wm"] + 0.16 * task_difficulty, 1.0), 0, 10)
            alignment_score = np.clip(rng.normal(cond["align"] - 0.05 * task_difficulty, 0.8), 0, 10)
            trust_score = np.clip(rng.normal(cond["trust"] + 0.10 * alignment_score - 0.10 * attentional_demand, 0.8), 0, 10)
            automation_reliance = np.clip(rng.normal(cond["auto"], 1.0), 0, 10)
            accessibility_friction = np.clip(rng.normal(cond["access"] + 0.06 * perceptual_load, 0.7), 0, 10)

            cognitive_load = np.clip(
                rng.normal(
                    0.25 * perceptual_load
                    + 0.28 * attentional_demand
                    + 0.25 * working_memory_load
                    + 0.18 * task_difficulty
                    + 0.10 * accessibility_friction
                    - 0.18 * alignment_score
                    + 2.2,
                    0.6,
                ),
                0,
                10,
            )

            success_logit = (
                2.2
                - 0.26 * task_difficulty
                - 0.30 * cognitive_load
                - 0.16 * accessibility_friction
                + 0.28 * alignment_score
                + 0.10 * trust_score
                + participant_skill
                + rng.normal(0, 0.30)
            )
            success = int(rng.random() < logistic(np.array([success_logit]))[0])

            warning_logit = (
                1.6
                - 0.30 * perceptual_load
                - 0.28 * attentional_demand
                + 0.25 * alignment_score
                + 0.10 * trust_score
                + rng.normal(0, 0.25)
            )
            warning_detected = int(rng.random() < logistic(np.array([warning_logit]))[0])

            error_lambda = np.exp(
                -0.9
                + 0.18 * task_difficulty
                + 0.20 * cognitive_load
                + 0.12 * accessibility_friction
                - 0.16 * alignment_score
            )
            error_count = int(np.clip(rng.poisson(error_lambda), 0, 25))

            log_rt = (
                math.log(1900)
                + 0.060 * task_difficulty
                + 0.060 * cognitive_load
                + 0.030 * perceptual_load
                + 0.020 * attentional_demand
                - 0.035 * alignment_score
                + participant_speed
                + rng.normal(0, 0.12)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 60000))

            rows.append(
                {
                    "participant": participant,
                    "interface_condition": interface_condition,
                    "task_id": task_id,
                    "trial": trial,
                    "task_difficulty": round(float(task_difficulty), 3),
                    "perceptual_load": round(float(perceptual_load), 3),
                    "attentional_demand": round(float(attentional_demand), 3),
                    "working_memory_load": round(float(working_memory_load), 3),
                    "cognitive_load": round(float(cognitive_load), 3),
                    "alignment_score": round(float(alignment_score), 3),
                    "trust_score": round(float(trust_score), 3),
                    "automation_reliance": round(float(automation_reliance), 3),
                    "accessibility_friction": round(float(accessibility_friction), 3),
                    "success": success,
                    "response_time_ms": response_time_ms,
                    "error_count": error_count,
                    "warning_detected": warning_detected,
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("interface_condition")
        .agg(
            n_trials=("success", "size"),
            participants=("participant", "nunique"),
            mean_task_difficulty=("task_difficulty", "mean"),
            mean_perceptual_load=("perceptual_load", "mean"),
            mean_attention=("attentional_demand", "mean"),
            mean_working_memory=("working_memory_load", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_alignment=("alignment_score", "mean"),
            mean_trust=("trust_score", "mean"),
            mean_accessibility_friction=("accessibility_friction", "mean"),
            success_rate=("success", "mean"),
            warning_detection_rate=("warning_detected", "mean"),
            mean_errors=("error_count", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_task = (
        df.groupby("task_id")
        .agg(
            n_trials=("success", "size"),
            mean_difficulty=("task_difficulty", "mean"),
            success_rate=("success", "mean"),
            mean_errors=("error_count", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_interface_condition.csv", index=False)
    by_task.to_csv(outputs / "summary_by_task.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    success_formula = (
        "success ~ interface_condition + task_difficulty + perceptual_load + "
        "attentional_demand + working_memory_load + cognitive_load + "
        "alignment_score + trust_score + accessibility_friction"
    )

    success_model = smf.glm(
        success_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Task-success model: logistic GLM ===\n")
    model_text.append(str(success_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ interface_condition + task_difficulty + perceptual_load + "
        "attentional_demand + working_memory_load + cognitive_load + "
        "alignment_score + accessibility_friction"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Response-time model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    error_formula = (
        "error_count ~ interface_condition + task_difficulty + perceptual_load + "
        "attentional_demand + working_memory_load + cognitive_load + "
        "alignment_score + accessibility_friction"
    )

    error_model = smf.glm(
        error_formula,
        data=df,
        family=sm.families.Poisson(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Error-count model: Poisson GLM ===\n")
    model_text.append(str(error_model.summary()))

    warning_formula = (
        "warning_detected ~ interface_condition + perceptual_load + attentional_demand + "
        "cognitive_load + alignment_score + trust_score"
    )

    warning_model = smf.glm(
        warning_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Warning-detection model: logistic GLM ===\n")
    model_text.append(str(warning_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": success_model.params.index,
            "success_coef": success_model.params.values,
            "success_se": success_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "success_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/hci_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=180)
    parser.add_argument("--trials", type=int, default=12)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = generate_dataset(
            n_participants=args.participants,
            trials_per_participant=args.trials,
            seed=args.seed,
        )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default_input = Path("data/hci_trials.csv")
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
