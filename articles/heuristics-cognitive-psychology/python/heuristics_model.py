#!/usr/bin/env python3
"""
Heuristics research model.

This script can:
1. Generate synthetic heuristic-judgment trial data.
2. Estimate models for anchoring, availability, representativeness, recognition,
   fluency, affect, strategy complexity, effort, response time, correctness,
   calibration error, bias magnitude, and adaptive fit.
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


CONDITIONS = [
    "control",
    "anchoring",
    "availability",
    "representativeness",
    "recognition",
    "fluency",
    "affect",
    "take_the_best",
    "tallying",
    "analytic",
]

DOMAINS = ["general", "risk", "health", "finance", "legal", "medical", "policy", "technology", "ai"]

HEURISTIC_MAP = {
    "control": "analytic",
    "anchoring": "anchoring",
    "availability": "availability",
    "representativeness": "representativeness",
    "recognition": "recognition",
    "fluency": "fluency",
    "affect": "affect",
    "take_the_best": "take_the_best",
    "tallying": "tallying",
    "analytic": "analytic",
}


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(n_participants: int = 280, trials_per_participant: int = 14, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"effort": 0.0, "complexity": 4.8, "cue_count": 4, "speed": 0.0, "bias": 0.0},
        "anchoring": {"effort": -1.4, "complexity": 2.2, "cue_count": 2, "speed": -0.22, "bias": 0.45},
        "availability": {"effort": -1.2, "complexity": 2.4, "cue_count": 2, "speed": -0.18, "bias": 0.38},
        "representativeness": {"effort": -1.0, "complexity": 2.8, "cue_count": 3, "speed": -0.16, "bias": 0.46},
        "recognition": {"effort": -1.8, "complexity": 1.8, "cue_count": 1, "speed": -0.26, "bias": 0.20},
        "fluency": {"effort": -1.5, "complexity": 2.0, "cue_count": 2, "speed": -0.24, "bias": 0.28},
        "affect": {"effort": -1.3, "complexity": 2.5, "cue_count": 2, "speed": -0.20, "bias": 0.36},
        "take_the_best": {"effort": -1.0, "complexity": 2.8, "cue_count": 2, "speed": -0.18, "bias": 0.08},
        "tallying": {"effort": -0.4, "complexity": 4.0, "cue_count": 5, "speed": -0.08, "bias": 0.10},
        "analytic": {"effort": 1.0, "complexity": 7.5, "cue_count": 8, "speed": 0.18, "bias": -0.15},
    }

    domain_predictability = {
        "general": 0.58,
        "risk": 0.48,
        "health": 0.62,
        "finance": 0.55,
        "legal": 0.50,
        "medical": 0.60,
        "policy": 0.45,
        "technology": 0.56,
        "ai": 0.52,
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        analytic_tendency = rng.normal(0, 0.55)
        susceptibility = rng.normal(0, 0.55)
        numeracy = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.15)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            ce = condition_effects[condition]
            heuristic_type = HEURISTIC_MAP[condition]
            scenario_id = f"H{trial:03d}_{participant}"

            true_probability = float(np.clip(rng.beta(2.0, 2.5), 0.02, 0.98))
            true_value = float(np.clip(rng.normal(100 * true_probability, 12), 0, 100))
            base_rate = float(np.clip(true_probability + rng.normal(0, 0.08), 0.02, 0.98))
            cue_validity = float(np.clip(rng.normal(domain_predictability[domain], 0.12), 0.20, 0.95))

            high_anchor = rng.random() < 0.50
            anchor_value = float(np.clip(true_value + (22 if high_anchor else -22) + rng.normal(0, 8), 0, 100))
            recall_ease = float(np.clip(rng.normal(4.8 + 3.2 * (condition == "availability") + 0.18 * 100 * true_probability / 10, 1.0), 0, 10))
            representativeness = float(np.clip(rng.normal(5.0 + 3.0 * (condition == "representativeness") + 0.5 * rng.normal(), 1.0), 0, 10))
            recognition_strength = float(np.clip(rng.normal(5.2 + 3.0 * (condition == "recognition") + 0.7 * cue_validity, 1.0), 0, 10))
            fluency = float(np.clip(rng.normal(5.0 + 3.0 * (condition == "fluency") + 0.5 * recognition_strength / 10, 1.0), 0, 10))
            affective_valence = float(np.clip(rng.normal(0.5 + 2.4 * (condition == "affect") + 0.4 * rng.normal(), 1.5), -5, 5))
            base_rate_use = float(np.clip(0.62 + 0.20 * (condition == "analytic") - 0.30 * (condition == "representativeness") - 0.12 * susceptibility + 0.12 * numeracy + rng.normal(0, 0.08), 0, 1))
            cue_count = int(np.clip(round(rng.normal(ce["cue_count"] + 1.2 * (condition == "analytic"), 1.0)), 1, 12))
            information_cost = float(np.clip(rng.normal(4.0 + 0.55 * cue_count - 0.25 * (condition in ["recognition", "fluency"]), 1.0), 0, 10))
            time_pressure = float(np.clip(rng.normal(5.0 + 1.8 * (condition != "analytic") - 0.8 * (condition == "analytic"), 1.2), 0, 10))
            cognitive_load = float(np.clip(rng.normal(4.5 + 0.30 * information_cost + 0.30 * time_pressure - 0.20 * analytic_tendency, 1.0), 0, 10))
            strategy_complexity = float(np.clip(rng.normal(ce["complexity"] + 0.3 * cue_count, 0.8), 0, 10))
            subjective_effort = float(np.clip(rng.normal(4.8 + ce["effort"] + 0.35 * strategy_complexity + 0.22 * cognitive_load, 0.9), 0, 10))

            anchor_component = 0.0
            if condition == "anchoring":
                anchor_component = 0.42 * (anchor_value - true_value) * (1.0 + 0.25 * susceptibility)

            availability_component = 0.0
            if condition == "availability":
                availability_component = 3.0 * (recall_ease - 5.0) + 0.08 * true_value

            represent_component = 0.0
            if condition == "representativeness":
                represent_component = 3.2 * (representativeness - 5.0) - 12.0 * base_rate_use

            recognition_component = 0.0
            if condition == "recognition":
                recognition_component = 2.0 * (recognition_strength - 5.0) * cue_validity

            fluency_component = 0.0
            if condition == "fluency":
                fluency_component = 2.2 * (fluency - 5.0)

            affect_component = 0.0
            if condition == "affect":
                affect_component = 3.5 * affective_valence

            analytic_component = 12.0 * (base_rate - 0.5) + 0.25 * (true_value - 50.0) + 2.5 * analytic_tendency

            estimate = float(
                np.clip(
                    true_value
                    + anchor_component
                    + availability_component
                    + represent_component
                    + recognition_component
                    + fluency_component
                    + affect_component
                    - 0.18 * cognitive_load * (condition == "analytic")
                    + 0.25 * analytic_component * (condition in ["control", "analytic", "tallying", "take_the_best"])
                    + rng.normal(0, 7.5),
                    0,
                    100,
                )
            )

            judged_probability = float(np.clip(estimate / 100.0 + rng.normal(0, 0.04), 0, 1))
            choice_latent = (
                -0.25
                + 2.2 * (judged_probability - 0.5)
                + 0.65 * (recognition_strength - 5.0) / 5.0 * (condition == "recognition")
                + 0.65 * affective_valence / 5.0 * (condition == "affect")
                + 0.42 * (fluency - 5.0) / 5.0 * (condition == "fluency")
                + rng.normal(0, 0.25)
            )
            choice_binary = int(rng.random() < logistic(np.array([choice_latent]))[0])

            criterion_binary = int(true_probability >= 0.50)
            correct_probability = logistic(
                np.array([
                    -0.35
                    + 2.4 * cue_validity
                    + 0.34 * base_rate_use
                    + 0.18 * cue_count
                    + 0.14 * analytic_tendency
                    - 0.15 * cognitive_load
                    - 0.22 * ce["bias"]
                    + 0.16 * (condition in ["take_the_best", "tallying"]) * cue_validity
                ])
            )[0]
            correct = int((choice_binary == criterion_binary and rng.random() < 0.80) or (rng.random() < max(0.05, correct_probability - 0.25)))

            rt_ms = int(
                np.clip(
                    np.exp(
                        math.log(1900)
                        + 0.055 * strategy_complexity
                        + 0.045 * subjective_effort
                        + 0.055 * cognitive_load
                        + 0.020 * cue_count
                        + ce["speed"]
                        + speed_factor
                        + rng.normal(0, 0.14)
                    ),
                    150,
                    60000,
                )
            )

            confidence = float(np.clip(rng.normal(5.2 + 0.18 * fluency + 0.16 * recognition_strength + 1.0 * correct - 0.12 * subjective_effort, 1.0), 0, 10))
            calibration_error = float(abs(judged_probability - true_probability))
            bias_magnitude = float(abs(estimate - true_value))
            benchmark_accuracy = 0.58 + 0.22 * cue_validity + 0.08 * numeracy
            heuristic_accuracy = correct_probability
            adaptive_fit = float(np.clip(heuristic_accuracy - benchmark_accuracy + rng.normal(0, 0.04), -1, 1))
            adjustment = float(estimate - anchor_value)

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "scenario_id": scenario_id,
                    "heuristic_type": heuristic_type,
                    "anchor_value": round(anchor_value, 3),
                    "adjustment": round(adjustment, 3),
                    "recall_ease": round(recall_ease, 3),
                    "representativeness": round(representativeness, 3),
                    "base_rate": round(base_rate, 4),
                    "base_rate_use": round(base_rate_use, 4),
                    "recognition_strength": round(recognition_strength, 3),
                    "fluency": round(fluency, 3),
                    "affective_valence": round(affective_valence, 3),
                    "cue_validity": round(cue_validity, 4),
                    "cue_count": cue_count,
                    "information_cost": round(information_cost, 3),
                    "time_pressure": round(time_pressure, 3),
                    "cognitive_load": round(cognitive_load, 3),
                    "strategy_complexity": round(strategy_complexity, 3),
                    "subjective_effort": round(subjective_effort, 3),
                    "judged_probability": round(judged_probability, 4),
                    "true_probability": round(true_probability, 4),
                    "estimate": round(estimate, 3),
                    "true_value": round(true_value, 3),
                    "choice_binary": choice_binary,
                    "correct": correct,
                    "rt_ms": rt_ms,
                    "confidence": round(confidence, 3),
                    "calibration_error": round(calibration_error, 4),
                    "bias_magnitude": round(bias_magnitude, 3),
                    "adaptive_fit": round(adaptive_fit, 4),
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
            mean_judged_probability=("judged_probability", "mean"),
            mean_true_probability=("true_probability", "mean"),
            mean_estimate=("estimate", "mean"),
            mean_true_value=("true_value", "mean"),
            choice_rate=("choice_binary", "mean"),
            correct_rate=("correct", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_bias_magnitude=("bias_magnitude", "mean"),
            mean_adaptive_fit=("adaptive_fit", "mean"),
            mean_effort=("subjective_effort", "mean"),
            mean_cue_count=("cue_count", "mean"),
        )
        .reset_index()
    )

    by_heuristic = (
        df.groupby("heuristic_type")
        .agg(
            n_trials=("correct", "size"),
            correct_rate=("correct", "mean"),
            mean_effort=("subjective_effort", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_bias_magnitude=("bias_magnitude", "mean"),
            mean_adaptive_fit=("adaptive_fit", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_heuristic.to_csv(outputs / "summary_by_heuristic.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    anchor_df = df[df["condition"].isin(["anchoring", "control", "analytic"])].copy()
    anchor_model = smf.ols(
        "estimate ~ anchor_value * condition + true_value + cognitive_load + subjective_effort",
        data=anchor_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": anchor_df["participant"]})
    model_text.append("\n\n=== Anchoring model ===\n")
    model_text.append(str(anchor_model.summary()))

    availability_df = df[df["condition"].isin(["availability", "control", "analytic"])].copy()
    availability_model = smf.ols(
        "judged_probability ~ recall_ease * condition + true_probability + affective_valence + cognitive_load",
        data=availability_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": availability_df["participant"]})
    model_text.append("\n\n=== Availability model ===\n")
    model_text.append(str(availability_model.summary()))

    represent_model = smf.ols(
        "judged_probability ~ representativeness * condition + base_rate + base_rate_use + true_probability + cognitive_load",
        data=df[df["condition"].isin(["representativeness", "control", "analytic"])],
    ).fit(cov_type="cluster", cov_kwds={"groups": df[df["condition"].isin(["representativeness", "control", "analytic"])]["participant"]})
    model_text.append("\n\n=== Representativeness and base-rate model ===\n")
    model_text.append(str(represent_model.summary()))

    correct_formula = (
        "correct ~ condition + domain + heuristic_type + cue_validity + cue_count + "
        "information_cost + time_pressure + cognitive_load + strategy_complexity + "
        "subjective_effort + base_rate_use + confidence"
    )
    correct_model = smf.glm(correct_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Correct-choice logistic model ===\n")
    model_text.append(str(correct_model.summary()))

    bias_model = smf.ols(
        "bias_magnitude ~ condition + domain + heuristic_type + anchor_value + recall_ease + "
        "representativeness + recognition_strength + fluency + affective_valence + base_rate_use + "
        "time_pressure + cognitive_load + subjective_effort",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Bias-magnitude model ===\n")
    model_text.append(str(bias_model.summary()))

    calibration_model = smf.ols(
        "calibration_error ~ condition + domain + heuristic_type + recall_ease + representativeness + "
        "base_rate_use + cue_validity + cognitive_load + confidence",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Calibration-error model ===\n")
    model_text.append(str(calibration_model.summary()))

    effort_model = smf.ols(
        "subjective_effort ~ condition + domain + heuristic_type + cue_count + information_cost + "
        "strategy_complexity + time_pressure + cognitive_load",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Subjective-effort model ===\n")
    model_text.append(str(effort_model.summary()))

    rt_df = df[df["rt_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["rt_ms"])
    rt_model = smf.ols(
        "log_rt ~ condition + domain + heuristic_type + cue_count + information_cost + "
        "time_pressure + cognitive_load + strategy_complexity + subjective_effort + correct",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    adaptive_model = smf.ols(
        "adaptive_fit ~ condition + domain + heuristic_type + cue_validity + cue_count + "
        "information_cost + time_pressure + cognitive_load + strategy_complexity",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Adaptive-fit model ===\n")
    model_text.append(str(adaptive_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    pd.DataFrame(
        {
            "term": correct_model.params.index,
            "correct_choice_coef": correct_model.params.values,
            "correct_choice_se": correct_model.bse.values,
        }
    ).to_csv(outputs / "correct_choice_model_coefficients.csv", index=False)

    pd.DataFrame(
        {
            "term": bias_model.params.index,
            "bias_magnitude_coef": bias_model.params.values,
            "bias_magnitude_se": bias_model.bse.values,
        }
    ).to_csv(outputs / "bias_magnitude_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/heuristics_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=280)
    parser.add_argument("--trials", type=int, default=14)
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
        default_input = Path("data/heuristics_trials.csv")
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
