#!/usr/bin/env python3
"""
Cognitive systems in artificial intelligence.

This script can:
1. Generate synthetic cognitive-systems trial data.
2. Estimate models for prediction accuracy, action success, explanation quality,
   human override behavior, response time, and calibration error.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is not intended to represent a real AI system.
It is a reproducible scaffold for cognitive psychology, AI, HCI,
and human-AI collaboration research.
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


ARCHITECTURES = [
    "symbolic",
    "neural",
    "hybrid",
    "retrieval_augmented",
    "reinforcement_learning",
]

TASK_CONDITIONS = [
    "baseline",
    "high_uncertainty",
    "memory_load",
    "human_ai_collaboration",
]


def logistic(x: np.ndarray) -> np.ndarray:
    """Numerically stable logistic transform."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_agents: int = 160,
    trials_per_agent: int = 16,
    seed: int = 42,
) -> pd.DataFrame:
    """Generate synthetic cognitive-systems trial data."""

    rng = np.random.default_rng(seed)
    rows = []

    architecture_effects: Dict[str, Dict[str, float]] = {
        "symbolic": {"repr": 7.0, "explain": 8.2, "latency": 160, "entropy": 1.5, "calib": 0.10},
        "neural": {"repr": 7.8, "explain": 5.4, "latency": 95, "entropy": 1.9, "calib": 0.14},
        "hybrid": {"repr": 8.3, "explain": 8.0, "latency": 135, "entropy": 1.4, "calib": 0.08},
        "retrieval_augmented": {"repr": 8.1, "explain": 7.5, "latency": 185, "entropy": 1.3, "calib": 0.09},
        "reinforcement_learning": {"repr": 6.7, "explain": 5.0, "latency": 110, "entropy": 2.2, "calib": 0.16},
    }

    condition_effects: Dict[str, Dict[str, float]] = {
        "baseline": {"noise": 2.8, "wm": 3.8, "uncertainty": 3.5},
        "high_uncertainty": {"noise": 6.8, "wm": 5.2, "uncertainty": 7.6},
        "memory_load": {"noise": 4.4, "wm": 8.1, "uncertainty": 5.6},
        "human_ai_collaboration": {"noise": 3.6, "wm": 4.8, "uncertainty": 4.6},
    }

    for agent_idx in range(1, n_agents + 1):
        agent_id = f"A{agent_idx:03d}"
        architecture = rng.choice(ARCHITECTURES)
        arch = architecture_effects[architecture]
        agent_skill = rng.normal(0, 0.04)
        agent_speed = rng.normal(0, 0.12)

        for trial in range(1, trials_per_agent + 1):
            task_condition = rng.choice(TASK_CONDITIONS)
            cond = condition_effects[task_condition]

            input_noise = np.clip(rng.normal(cond["noise"], 1.0), 0, 10)
            wm_load = np.clip(rng.normal(cond["wm"], 1.2), 0, 10)
            uncertainty = np.clip(rng.normal(cond["uncertainty"], 1.1), 0, 10)

            representation_quality = np.clip(
                rng.normal(
                    arch["repr"]
                    - 0.16 * input_noise
                    - 0.08 * uncertainty
                    + (0.45 if architecture == "hybrid" else 0.0),
                    0.7,
                ),
                0,
                10,
            )

            retrieval_latency_ms = np.clip(
                rng.normal(
                    arch["latency"] + 21 * wm_load + 12 * uncertainty,
                    38,
                ),
                20,
                2500,
            )

            policy_entropy = np.clip(
                rng.normal(
                    arch["entropy"] + 0.14 * uncertainty + 0.05 * input_noise - 0.06 * representation_quality,
                    0.35,
                ),
                0,
                5,
            )

            prediction_accuracy = np.clip(
                0.50
                + 0.045 * representation_quality
                - 0.030 * uncertainty
                - 0.018 * input_noise
                - 0.020 * policy_entropy
                + agent_skill
                + rng.normal(0, 0.045),
                0,
                1,
            )

            action_logit = (
                -2.0
                + 5.2 * prediction_accuracy
                + 0.18 * representation_quality
                - 0.35 * policy_entropy
                - 0.12 * uncertainty
                + rng.normal(0, 0.25)
            )
            action_success = int(rng.random() < logistic(np.array([action_logit]))[0])

            explanation_score = np.clip(
                rng.normal(
                    arch["explain"]
                    + 0.12 * representation_quality
                    - 0.10 * uncertainty
                    - 0.08 * policy_entropy,
                    0.8,
                ),
                0,
                10,
            )

            calibration_error = np.clip(
                rng.normal(
                    arch["calib"] + 0.018 * uncertainty + 0.012 * policy_entropy - 0.010 * representation_quality,
                    0.035,
                ),
                0,
                1,
            )

            human_trust = np.clip(
                rng.normal(
                    4.2
                    + 0.48 * explanation_score
                    + 1.10 * prediction_accuracy
                    - 1.6 * calibration_error
                    - 0.12 * uncertainty,
                    0.8,
                ),
                0,
                10,
            )

            override_logit = (
                1.8
                - 0.42 * explanation_score
                - 0.20 * human_trust
                + 3.0 * calibration_error
                + 0.10 * uncertainty
                - 1.2 * action_success
            )
            override_decision = int(rng.random() < logistic(np.array([override_logit]))[0])

            log_rt = (
                math.log(420)
                + 0.0025 * retrieval_latency_ms
                + 0.025 * wm_load
                + 0.030 * uncertainty
                + 0.045 * policy_entropy
                + agent_speed
                + rng.normal(0, 0.10)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 50, 10000))

            rows.append(
                {
                    "agent_id": agent_id,
                    "architecture": architecture,
                    "task_condition": task_condition,
                    "trial": trial,
                    "input_noise": round(float(input_noise), 3),
                    "representation_quality": round(float(representation_quality), 3),
                    "working_memory_load": round(float(wm_load), 3),
                    "retrieval_latency_ms": round(float(retrieval_latency_ms), 3),
                    "uncertainty_level": round(float(uncertainty), 3),
                    "policy_entropy": round(float(policy_entropy), 3),
                    "prediction_accuracy": round(float(prediction_accuracy), 3),
                    "action_success": action_success,
                    "explanation_score": round(float(explanation_score), 3),
                    "human_trust": round(float(human_trust), 3),
                    "override_decision": override_decision,
                    "response_time_ms": response_time_ms,
                    "calibration_error": round(float(calibration_error), 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    """Save descriptive summaries by architecture and task condition."""

    outputs.mkdir(parents=True, exist_ok=True)

    by_architecture = (
        df.groupby("architecture")
        .agg(
            n_trials=("prediction_accuracy", "size"),
            agents=("agent_id", "nunique"),
            mean_representation=("representation_quality", "mean"),
            mean_retrieval_latency_ms=("retrieval_latency_ms", "mean"),
            mean_uncertainty=("uncertainty_level", "mean"),
            mean_policy_entropy=("policy_entropy", "mean"),
            mean_prediction_accuracy=("prediction_accuracy", "mean"),
            action_success_rate=("action_success", "mean"),
            mean_explanation=("explanation_score", "mean"),
            mean_human_trust=("human_trust", "mean"),
            override_rate=("override_decision", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition = (
        df.groupby("task_condition")
        .agg(
            n_trials=("prediction_accuracy", "size"),
            mean_input_noise=("input_noise", "mean"),
            mean_working_memory_load=("working_memory_load", "mean"),
            mean_uncertainty=("uncertainty_level", "mean"),
            mean_prediction_accuracy=("prediction_accuracy", "mean"),
            action_success_rate=("action_success", "mean"),
            mean_explanation=("explanation_score", "mean"),
            override_rate=("override_decision", "mean"),
        )
        .reset_index()
    )

    by_architecture.to_csv(outputs / "summary_by_architecture.csv", index=False)
    by_condition.to_csv(outputs / "summary_by_task_condition.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    """Estimate statistical models and save summaries."""

    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    prediction_formula = (
        "prediction_accuracy ~ architecture + task_condition + input_noise + "
        "representation_quality + working_memory_load + retrieval_latency_ms + "
        "uncertainty_level + policy_entropy"
    )

    prediction_model = smf.ols(prediction_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["agent_id"]},
    )
    model_text.append("\n\n=== Prediction-accuracy model: cluster-robust OLS ===\n")
    model_text.append(str(prediction_model.summary()))

    success_formula = (
        "action_success ~ architecture + task_condition + input_noise + "
        "representation_quality + working_memory_load + retrieval_latency_ms + "
        "uncertainty_level + policy_entropy + prediction_accuracy"
    )

    success_model = smf.glm(
        success_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["agent_id"]},
    )
    model_text.append("\n\n=== Action-success model: logistic GLM ===\n")
    model_text.append(str(success_model.summary()))

    explanation_formula = (
        "explanation_score ~ architecture + task_condition + representation_quality + "
        "uncertainty_level + policy_entropy + calibration_error"
    )

    explanation_model = smf.ols(explanation_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["agent_id"]},
    )
    model_text.append("\n\n=== Explanation-score model ===\n")
    model_text.append(str(explanation_model.summary()))

    override_formula = (
        "override_decision ~ architecture + task_condition + explanation_score + "
        "human_trust + calibration_error + uncertainty_level + action_success"
    )

    override_model = smf.glm(
        override_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["agent_id"]},
    )
    model_text.append("\n\n=== Human-override model: logistic GLM ===\n")
    model_text.append(str(override_model.summary()))

    rt_df = df[df["response_time_ms"] >= 1].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ architecture + task_condition + retrieval_latency_ms + "
        "working_memory_load + uncertainty_level + policy_entropy"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["agent_id"]},
    )
    model_text.append("\n\n=== Response-time model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coef = pd.DataFrame(
        {
            "term": prediction_model.params.index,
            "prediction_coef": prediction_model.params.values,
            "prediction_se": prediction_model.bse.values,
        }
    )
    coef.to_csv(outputs / "prediction_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/cognitive_systems_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--agents", type=int, default=160)
    parser.add_argument("--trials", type=int, default=16)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = generate_dataset(
            n_agents=args.agents,
            trials_per_agent=args.trials,
            seed=args.seed,
        )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default_input = Path("data/cognitive_systems_trials.csv")
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
