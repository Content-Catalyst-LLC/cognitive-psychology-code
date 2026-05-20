#!/usr/bin/env python3
"""
Metacognition research model.

This script can:
1. Generate synthetic metacognition trial data.
2. Estimate models for calibration error, signed calibration, strategy shift,
   review choice, feedback use, study time, and response time.
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
    "feedback",
    "metacognitive_prompt",
    "high_difficulty",
    "time_pressure",
    "strategy_training",
    "uncertainty_display",
]

DOMAINS = ["memory", "learning", "problem_solving", "decision_making", "reasoning"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 240,
    trials_per_participant: int = 14,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"difficulty": 5.0, "evidence": 5.8, "prompt": 0, "feedback": 0, "time": 0, "training": 0},
        "feedback": {"difficulty": 5.6, "evidence": 6.4, "prompt": 0, "feedback": 1, "time": 0, "training": 0},
        "metacognitive_prompt": {"difficulty": 5.8, "evidence": 6.0, "prompt": 1, "feedback": 0, "time": 0, "training": 0},
        "high_difficulty": {"difficulty": 8.2, "evidence": 4.4, "prompt": 0, "feedback": 0, "time": 0, "training": 0},
        "time_pressure": {"difficulty": 6.4, "evidence": 4.8, "prompt": 0, "feedback": 0, "time": 1, "training": 0},
        "strategy_training": {"difficulty": 6.2, "evidence": 6.0, "prompt": 1, "feedback": 1, "time": 0, "training": 1},
        "uncertainty_display": {"difficulty": 6.0, "evidence": 5.6, "prompt": 1, "feedback": 1, "time": 0, "training": 0},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        metacognitive_skill = rng.normal(0, 0.55)
        general_ability = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]
            domain = rng.choice(DOMAINS)
            task_id = f"MC{trial:03d}_{participant}"

            task_difficulty = np.clip(rng.normal(params["difficulty"], 0.9), 0, 10)
            evidence_quality = np.clip(rng.normal(params["evidence"], 0.9), 0, 10)

            accuracy_logit = (
                0.2
                + 0.40 * general_ability
                + 0.25 * evidence_quality
                - 0.32 * task_difficulty
                - 0.35 * params["time"]
                + rng.normal(0, 0.30)
            )
            actual_accuracy = int(rng.random() < logistic(np.array([accuracy_logit]))[0])

            monitoring_noise = np.clip(0.25 - 0.05 * metacognitive_skill - 0.025 * params["prompt"] - 0.020 * params["training"], 0.05, 0.45)
            base_confidence = (
                0.48
                + 0.26 * actual_accuracy
                - 0.030 * task_difficulty
                + 0.020 * evidence_quality
                + 0.045 * general_ability
                + 0.060 * metacognitive_skill
                - 0.040 * params["time"]
            )
            confidence_rating = float(np.clip(rng.normal(base_confidence, monitoring_noise), 0, 1))
            uncertainty_rating = float(np.clip(1.0 - confidence_rating + rng.normal(0, 0.08), 0, 1))
            judgment_of_learning = float(np.clip(rng.normal(0.55 + 0.40 * confidence_rating - 0.02 * task_difficulty + 0.06 * params["feedback"], 0.10), 0, 1))
            feeling_of_knowing = float(np.clip(rng.normal(0.50 + 0.32 * confidence_rating + 0.03 * evidence_quality - 0.02 * task_difficulty, 0.12), 0, 1))

            calibration_error = abs(confidence_rating - actual_accuracy)

            shift_logit = (
                -1.2
                + 1.7 * uncertainty_rating
                + 0.18 * task_difficulty
                - 1.1 * confidence_rating
                + 0.35 * params["prompt"]
                + 0.35 * params["training"]
                + 0.25 * params["feedback"]
                + 0.40 * metacognitive_skill
                + rng.normal(0, 0.25)
            )
            strategy_shift = int(rng.random() < logistic(np.array([shift_logit]))[0])

            review_logit = (
                -1.0
                + 1.8 * calibration_error
                + 1.2 * uncertainty_rating
                + 0.16 * task_difficulty
                + 0.25 * params["prompt"]
                + 0.22 * params["feedback"]
                + 0.25 * metacognitive_skill
                + rng.normal(0, 0.25)
            )
            review_choice = int(rng.random() < logistic(np.array([review_logit]))[0])

            feedback_logit = (
                -1.0
                + 0.65 * params["feedback"]
                + 0.45 * params["training"]
                + 0.30 * params["prompt"]
                + 0.90 * uncertainty_rating
                + 0.25 * metacognitive_skill
                + rng.normal(0, 0.25)
            )
            feedback_used = int(rng.random() < logistic(np.array([feedback_logit]))[0])

            study_time_seconds = float(np.clip(
                rng.normal(
                    15
                    + 3.0 * task_difficulty
                    + 18.0 * uncertainty_rating
                    - 8.0 * confidence_rating
                    + 7.0 * review_choice
                    + 5.0 * strategy_shift
                    - 6.0 * params["time"],
                    5.5,
                ),
                0,
                180,
            ))

            response_time_ms = int(np.clip(
                np.exp(
                    math.log(1400)
                    + 0.055 * task_difficulty
                    + 0.060 * uncertainty_rating
                    - 0.030 * confidence_rating
                    + 0.040 * strategy_shift
                    - 0.18 * params["time"]
                    + speed_factor
                    + rng.normal(0, 0.12)
                ),
                150,
                120000,
            ))

            metacognitive_regulation_score = float(np.clip(
                rng.normal(
                    4.0
                    + 1.5 * metacognitive_skill
                    + 1.2 * strategy_shift
                    + 0.8 * feedback_used
                    + 0.7 * review_choice
                    - 2.2 * calibration_error
                    + 0.3 * params["training"]
                    + 0.3 * params["prompt"],
                    0.9,
                ),
                0,
                10,
            ))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "trial": trial,
                    "task_id": task_id,
                    "domain": domain,
                    "task_difficulty": round(float(task_difficulty), 3),
                    "evidence_quality": round(float(evidence_quality), 3),
                    "confidence_rating": round(confidence_rating, 3),
                    "uncertainty_rating": round(uncertainty_rating, 3),
                    "actual_accuracy": actual_accuracy,
                    "judgment_of_learning": round(judgment_of_learning, 3),
                    "feeling_of_knowing": round(feeling_of_knowing, 3),
                    "strategy_shift": strategy_shift,
                    "review_choice": review_choice,
                    "feedback_used": feedback_used,
                    "study_time_seconds": round(study_time_seconds, 3),
                    "response_time_ms": response_time_ms,
                    "metacognitive_regulation_score": round(metacognitive_regulation_score, 3),
                }
            )

    df = pd.DataFrame(rows)
    df["calibration_error"] = (df["confidence_rating"] - df["actual_accuracy"]).abs()
    df["signed_calibration"] = df["confidence_rating"] - df["actual_accuracy"]
    return df


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if "calibration_error" not in df.columns:
        df["calibration_error"] = (df["confidence_rating"] - df["actual_accuracy"]).abs()
    if "signed_calibration" not in df.columns:
        df["signed_calibration"] = df["confidence_rating"] - df["actual_accuracy"]

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("actual_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_difficulty=("task_difficulty", "mean"),
            mean_evidence_quality=("evidence_quality", "mean"),
            mean_confidence=("confidence_rating", "mean"),
            mean_uncertainty=("uncertainty_rating", "mean"),
            accuracy_rate=("actual_accuracy", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_signed_calibration=("signed_calibration", "mean"),
            strategy_shift_rate=("strategy_shift", "mean"),
            review_choice_rate=("review_choice", "mean"),
            feedback_use_rate=("feedback_used", "mean"),
            mean_study_time_seconds=("study_time_seconds", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_regulation_score=("metacognitive_regulation_score", "mean"),
        )
        .reset_index()
    )

    by_domain = (
        df.groupby("domain")
        .agg(
            n_trials=("actual_accuracy", "size"),
            accuracy_rate=("actual_accuracy", "mean"),
            mean_confidence=("confidence_rating", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            strategy_shift_rate=("strategy_shift", "mean"),
            mean_regulation_score=("metacognitive_regulation_score", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_domain.to_csv(outputs / "summary_by_domain.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if "calibration_error" not in df.columns:
        df["calibration_error"] = (df["confidence_rating"] - df["actual_accuracy"]).abs()
    if "signed_calibration" not in df.columns:
        df["signed_calibration"] = df["confidence_rating"] - df["actual_accuracy"]

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    cal_formula = (
        "calibration_error ~ condition + domain + task_difficulty + evidence_quality + "
        "uncertainty_rating + judgment_of_learning + feedback_used"
    )
    cal_model = smf.ols(cal_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Calibration error model ===\n")
    model_text.append(str(cal_model.summary()))

    signed_formula = (
        "signed_calibration ~ condition + domain + task_difficulty + evidence_quality + "
        "actual_accuracy + uncertainty_rating"
    )
    signed_model = smf.ols(signed_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Signed calibration model ===\n")
    model_text.append(str(signed_model.summary()))

    shift_formula = (
        "strategy_shift ~ condition + domain + confidence_rating + uncertainty_rating + "
        "actual_accuracy + task_difficulty + evidence_quality + feedback_used"
    )
    shift_model = smf.glm(
        shift_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Strategy-shift model ===\n")
    model_text.append(str(shift_model.summary()))

    review_formula = (
        "review_choice ~ condition + domain + calibration_error + uncertainty_rating + "
        "task_difficulty + confidence_rating + feedback_used"
    )
    review_model = smf.glm(
        review_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Review-choice model ===\n")
    model_text.append(str(review_model.summary()))

    regulation_formula = (
        "metacognitive_regulation_score ~ condition + domain + calibration_error + "
        "strategy_shift + review_choice + feedback_used + task_difficulty + evidence_quality"
    )
    regulation_model = smf.ols(regulation_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Regulation-quality model ===\n")
    model_text.append(str(regulation_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])
    rt_formula = (
        "log_response_time ~ condition + domain + task_difficulty + confidence_rating + "
        "uncertainty_rating + strategy_shift + actual_accuracy"
    )
    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": cal_model.params.index,
            "calibration_coef": cal_model.params.values,
            "calibration_se": cal_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "calibration_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/metacognition_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=240)
    parser.add_argument("--trials", type=int, default=14)
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
        default_input = Path("data/metacognition_trials.csv")
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
