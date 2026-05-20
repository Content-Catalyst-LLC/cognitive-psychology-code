#!/usr/bin/env python3
"""
Cognitive constraints in organizational decision making.

This script can:
1. Generate synthetic organizational decision data.
2. Estimate models for decision quality, satisficing, and response time.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is not intended to represent a real organization.
It is a reproducible scaffold for cognitive psychology and organizational
decision research.
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


CONDITIONS = ["baseline", "overload", "dashboard_support", "deliberative_review"]
UNITS = ["Strategy", "Operations", "Compliance", "Product", "Finance", "Research"]


def logistic(x: np.ndarray) -> np.ndarray:
    """Numerically stable logistic transform."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 180,
    trials_per_participant: int = 12,
    seed: int = 42,
) -> pd.DataFrame:
    """Generate synthetic organizational decision trials."""

    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "baseline": {
            "info": 4.0,
            "attention": 6.5,
            "uncertainty": 4.5,
            "coordination": 4.5,
            "pressure": 4.0,
            "delay": 3.5,
            "safety": 6.5,
            "automation": 3.0,
        },
        "overload": {
            "info": 8.0,
            "attention": 4.8,
            "uncertainty": 7.2,
            "coordination": 7.0,
            "pressure": 6.8,
            "delay": 6.5,
            "safety": 4.8,
            "automation": 5.5,
        },
        "dashboard_support": {
            "info": 6.0,
            "attention": 6.8,
            "uncertainty": 5.4,
            "coordination": 5.4,
            "pressure": 4.8,
            "delay": 4.0,
            "safety": 6.3,
            "automation": 7.5,
        },
        "deliberative_review": {
            "info": 4.6,
            "attention": 8.0,
            "uncertainty": 4.8,
            "coordination": 5.8,
            "pressure": 3.8,
            "delay": 3.8,
            "safety": 8.0,
            "automation": 3.8,
        },
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        unit = rng.choice(UNITS)
        participant_skill = rng.normal(0, 4.0)
        participant_speed = rng.normal(0, 0.18)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]

            info_load = np.clip(rng.normal(params["info"], 1.1), 0, 10)
            attention = np.clip(rng.normal(params["attention"], 1.0), 0, 10)
            uncertainty = np.clip(rng.normal(params["uncertainty"], 1.1), 0, 10)
            coordination = np.clip(rng.normal(params["coordination"], 1.2), 0, 10)
            pressure = np.clip(rng.normal(params["pressure"], 1.2), 0, 10)
            delay = np.clip(rng.normal(params["delay"], 1.1), 0, 10)
            safety = np.clip(rng.normal(params["safety"], 1.0), 0, 10)
            automation = np.clip(rng.normal(params["automation"], 1.0), 0, 10)

            dissent_probability = logistic(np.array([-0.6 + 0.28 * safety - 0.18 * pressure]))[0]
            dissent_present = int(rng.random() < dissent_probability)

            cognitive_burden = (
                info_load
                + uncertainty
                + coordination
                + pressure
                + 0.5 * delay
                + 0.25 * automation
                - 0.55 * safety
                - 0.9 * dissent_present
            )

            quality_mean = (
                82
                - 2.1 * info_load
                - 1.7 * uncertainty
                - 1.2 * coordination
                - 1.5 * pressure
                - 0.7 * delay
                - 0.45 * automation
                + 2.4 * attention
                + 1.7 * safety
                + 3.2 * dissent_present
                + participant_skill
            )

            decision_quality = np.clip(rng.normal(quality_mean, 6.5), 0, 100)

            satisficing_linear = (
                -3.0
                + 0.32 * info_load
                + 0.28 * uncertainty
                + 0.24 * coordination
                + 0.26 * pressure
                + 0.12 * delay
                - 0.22 * attention
                - 0.20 * safety
                - 0.45 * dissent_present
                + rng.normal(0, 0.25)
            )
            chose_satisficing = int(rng.random() < logistic(np.array([satisficing_linear]))[0])

            log_rt = (
                math.log(2200)
                + 0.055 * info_load
                + 0.045 * uncertainty
                + 0.040 * coordination
                + 0.022 * pressure
                + 0.030 * delay
                - 0.020 * attention
                + participant_speed
                + rng.normal(0, 0.12)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 250, 15000))

            rows.append(
                {
                    "participant": participant,
                    "unit": unit,
                    "condition": condition,
                    "trial": trial,
                    "info_load": round(float(info_load), 3),
                    "attention_score": round(float(attention), 3),
                    "uncertainty_level": round(float(uncertainty), 3),
                    "coordination_load": round(float(coordination), 3),
                    "institutional_pressure": round(float(pressure), 3),
                    "feedback_delay": round(float(delay), 3),
                    "psychological_safety": round(float(safety), 3),
                    "dissent_present": dissent_present,
                    "automation_reliance": round(float(automation), 3),
                    "cognitive_burden": round(float(cognitive_burden), 3),
                    "decision_quality": round(float(decision_quality), 3),
                    "chose_satisficing": chose_satisficing,
                    "response_time_ms": response_time_ms,
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    """Save descriptive summaries by condition and unit."""

    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("decision_quality", "size"),
            participants=("participant", "nunique"),
            mean_info_load=("info_load", "mean"),
            mean_attention=("attention_score", "mean"),
            mean_uncertainty=("uncertainty_level", "mean"),
            mean_coordination=("coordination_load", "mean"),
            mean_pressure=("institutional_pressure", "mean"),
            mean_feedback_delay=("feedback_delay", "mean"),
            mean_safety=("psychological_safety", "mean"),
            dissent_rate=("dissent_present", "mean"),
            mean_automation=("automation_reliance", "mean"),
            mean_cognitive_burden=("cognitive_burden", "mean"),
            mean_quality=("decision_quality", "mean"),
            satisficing_rate=("chose_satisficing", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_unit = (
        df.groupby("unit")
        .agg(
            n_trials=("decision_quality", "size"),
            participants=("participant", "nunique"),
            mean_cognitive_burden=("cognitive_burden", "mean"),
            mean_quality=("decision_quality", "mean"),
            satisficing_rate=("chose_satisficing", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_unit.to_csv(outputs / "summary_by_unit.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    """Estimate statistical models and save summaries."""

    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    quality_formula = (
        "decision_quality ~ info_load + attention_score + uncertainty_level + "
        "coordination_load + institutional_pressure + feedback_delay + "
        "psychological_safety + dissent_present + automation_reliance + condition"
    )

    quality_model = smf.ols(quality_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Decision quality model: cluster-robust OLS ===\n")
    model_text.append(str(quality_model.summary()))

    satisficing_formula = (
        "chose_satisficing ~ info_load + attention_score + uncertainty_level + "
        "coordination_load + institutional_pressure + feedback_delay + "
        "psychological_safety + dissent_present + automation_reliance + condition"
    )

    satisficing_model = smf.glm(
        satisficing_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Satisficing model: logistic GLM ===\n")
    model_text.append(str(satisficing_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ info_load + attention_score + uncertainty_level + "
        "coordination_load + institutional_pressure + feedback_delay + "
        "psychological_safety + dissent_present + automation_reliance + condition"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Response-time model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    burden_model = smf.ols(
        "decision_quality ~ cognitive_burden + condition",
        data=df,
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Cognitive burden model ===\n")
    model_text.append(str(burden_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": quality_model.params.index,
            "quality_coef": quality_model.params.values,
            "quality_se": quality_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "quality_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/organizational_decision_trials.csv"))
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
        default_input = Path("data/organizational_decision_trials.csv")
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
