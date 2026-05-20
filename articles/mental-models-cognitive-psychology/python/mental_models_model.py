#!/usr/bin/env python3
"""
Mental models research model.

This script can:
1. Generate synthetic mental-model trial data.
2. Estimate models for prediction error, system understanding, problem success,
   intervention accuracy, model revision, transfer, reasoning time, cognitive load,
   and explanation quality.
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
    "model_training",
    "diagram_prompt",
    "feedback",
    "expert_comparison",
    "hci_task",
    "complex_system",
    "ai_assisted",
]

DOMAINS = ["mechanical", "ecological", "organizational", "economic", "interface", "policy", "clinical", "infrastructure"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(n_participants: int = 240, trials_per_participant: int = 12, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"quality": 4.8, "feedback": 0.0, "diagram": 0.0, "complexity": 4.8, "ai": 0.0},
        "model_training": {"quality": 7.2, "feedback": 0.4, "diagram": 0.4, "complexity": 5.6, "ai": 0.0},
        "diagram_prompt": {"quality": 6.4, "feedback": 0.2, "diagram": 1.0, "complexity": 5.2, "ai": 0.0},
        "feedback": {"quality": 6.2, "feedback": 1.0, "diagram": 0.2, "complexity": 5.4, "ai": 0.0},
        "expert_comparison": {"quality": 8.0, "feedback": 0.8, "diagram": 0.5, "complexity": 6.0, "ai": 0.0},
        "hci_task": {"quality": 5.8, "feedback": 0.2, "diagram": 0.6, "complexity": 5.0, "ai": 0.0},
        "complex_system": {"quality": 5.8, "feedback": 0.4, "diagram": 0.4, "complexity": 8.0, "ai": 0.0},
        "ai_assisted": {"quality": 7.0, "feedback": 0.6, "diagram": 0.5, "complexity": 6.2, "ai": 1.0},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        domain_knowledge = rng.normal(0, 0.55)
        model_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.15)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            ce = condition_effects[condition]
            scenario_id = f"MM{trial:03d}_{participant}"

            complexity = np.clip(rng.normal(ce["complexity"], 0.9), 0, 10)
            base_quality = ce["quality"] + 0.45 * domain_knowledge + 0.55 * model_skill

            model_completeness = np.clip(rng.normal(base_quality + 0.20 * ce["diagram"], 0.9), 0, 10)
            model_coherence = np.clip(rng.normal(base_quality + 0.15 * ce["diagram"] - 0.08 * complexity, 0.9), 0, 10)
            causal_link_accuracy = np.clip(rng.normal(base_quality + 0.25 * ce["feedback"] - 0.06 * complexity, 0.9), 0, 10)
            feedback_loop_recognition = np.clip(rng.normal(base_quality - 1.2 + 0.45 * ce["feedback"] + 0.35 * ce["diagram"] - 0.05 * complexity, 1.0), 0, 10)
            boundary_accuracy = np.clip(rng.normal(base_quality + 0.15 * domain_knowledge - 0.06 * complexity, 0.9), 0, 10)
            structural_similarity = np.clip(rng.normal(6.0 + 0.35 * ce["diagram"] + 0.25 * domain_knowledge, 1.0), 0, 10)

            latent_model_quality = (
                0.20 * model_completeness
                + 0.20 * model_coherence
                + 0.22 * causal_link_accuracy
                + 0.16 * feedback_loop_recognition
                + 0.14 * boundary_accuracy
                + 0.08 * structural_similarity
            )

            system_understanding_score = np.clip(
                rng.normal(
                    8.5 * latent_model_quality
                    + 2.2 * ce["feedback"]
                    + 1.6 * ce["diagram"]
                    - 1.8 * complexity,
                    5.0,
                ),
                0,
                100,
            )

            prediction_error = np.clip(
                rng.normal(
                    28
                    - 2.2 * latent_model_quality
                    - 0.06 * system_understanding_score
                    + 1.8 * complexity
                    - 1.8 * ce["feedback"]
                    + 0.5 * ce["ai"],
                    3.5,
                ),
                0,
                100,
            )

            success_logit = (
                -2.2
                + 0.08 * system_understanding_score
                + 0.16 * causal_link_accuracy
                + 0.12 * feedback_loop_recognition
                - 0.10 * prediction_error
                - 0.08 * complexity
                + 0.20 * ce["feedback"]
                + 0.10 * ce["ai"]
                + rng.normal(0, 0.25)
            )
            problem_success = int(rng.random() < logistic(np.array([success_logit]))[0])

            intervention_logit = (
                -2.0
                + 0.12 * causal_link_accuracy
                + 0.12 * feedback_loop_recognition
                + 0.08 * boundary_accuracy
                + 0.04 * system_understanding_score
                - 0.08 * complexity
                + rng.normal(0, 0.25)
            )
            intervention_choice_accuracy = int(rng.random() < logistic(np.array([intervention_logit]))[0])

            model_revision_score = np.clip(
                rng.normal(
                    2.5
                    + 0.28 * ce["feedback"]
                    + 0.24 * ce["diagram"]
                    + 0.35 * model_skill
                    + 0.35 * (prediction_error / 10.0)
                    + 0.15 * causal_link_accuracy,
                    0.9,
                ),
                0,
                10,
            )

            transfer_score = np.clip(
                rng.normal(
                    22
                    + 3.2 * structural_similarity
                    + 3.4 * model_coherence
                    + 2.5 * causal_link_accuracy
                    + 1.9 * boundary_accuracy
                    + 1.8 * problem_success
                    - 1.8 * complexity,
                    6.0,
                ),
                0,
                100,
            )

            cognitive_load = np.clip(
                rng.normal(
                    8.0
                    + 0.25 * complexity
                    - 0.32 * model_coherence
                    - 0.20 * model_completeness
                    - 0.15 * ce["diagram"]
                    + 0.20 * ce["ai"],
                    0.9,
                ),
                0,
                10,
            )

            confidence = np.clip(
                rng.normal(
                    3.0
                    + 0.08 * system_understanding_score
                    - 0.08 * prediction_error
                    + 0.45 * problem_success
                    + 0.35 * ce["ai"],
                    0.8,
                ),
                0,
                10,
            )

            reasoning_time_ms = int(
                np.clip(
                    np.exp(
                        math.log(2200)
                        + 0.055 * complexity
                        + 0.045 * cognitive_load
                        - 0.040 * model_coherence
                        - 0.030 * problem_success
                        - 0.070 * ce["ai"]
                        + speed_factor
                        + rng.normal(0, 0.12)
                    ),
                    150,
                    120000,
                )
            )

            explanation_quality = np.clip(
                rng.normal(
                    1.2
                    + 0.28 * model_completeness
                    + 0.25 * model_coherence
                    + 0.25 * causal_link_accuracy
                    + 0.16 * feedback_loop_recognition
                    + 0.10 * boundary_accuracy
                    - 0.05 * cognitive_load,
                    0.8,
                ),
                0,
                10,
            )

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "scenario_id": scenario_id,
                    "model_completeness": round(float(model_completeness), 3),
                    "model_coherence": round(float(model_coherence), 3),
                    "causal_link_accuracy": round(float(causal_link_accuracy), 3),
                    "feedback_loop_recognition": round(float(feedback_loop_recognition), 3),
                    "boundary_accuracy": round(float(boundary_accuracy), 3),
                    "structural_similarity": round(float(structural_similarity), 3),
                    "prediction_error": round(float(prediction_error), 3),
                    "system_understanding_score": round(float(system_understanding_score), 3),
                    "problem_success": problem_success,
                    "intervention_choice_accuracy": intervention_choice_accuracy,
                    "model_revision_score": round(float(model_revision_score), 3),
                    "transfer_score": round(float(transfer_score), 3),
                    "reasoning_time_ms": reasoning_time_ms,
                    "confidence": round(float(confidence), 3),
                    "cognitive_load": round(float(cognitive_load), 3),
                    "explanation_quality": round(float(explanation_quality), 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("problem_success", "size"),
            participants=("participant", "nunique"),
            mean_completeness=("model_completeness", "mean"),
            mean_coherence=("model_coherence", "mean"),
            mean_causal_accuracy=("causal_link_accuracy", "mean"),
            mean_feedback_loop_recognition=("feedback_loop_recognition", "mean"),
            mean_boundary_accuracy=("boundary_accuracy", "mean"),
            mean_structural_similarity=("structural_similarity", "mean"),
            mean_prediction_error=("prediction_error", "mean"),
            mean_system_understanding=("system_understanding_score", "mean"),
            success_rate=("problem_success", "mean"),
            intervention_accuracy=("intervention_choice_accuracy", "mean"),
            mean_revision=("model_revision_score", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_reasoning_time_ms=("reasoning_time_ms", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_explanation_quality=("explanation_quality", "mean"),
        )
        .reset_index()
    )

    by_domain = (
        df.groupby("domain")
        .agg(
            n_trials=("problem_success", "size"),
            mean_prediction_error=("prediction_error", "mean"),
            mean_system_understanding=("system_understanding_score", "mean"),
            success_rate=("problem_success", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_domain.to_csv(outputs / "summary_by_domain.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    err_formula = (
        "prediction_error ~ condition + domain + model_completeness + model_coherence + "
        "causal_link_accuracy + feedback_loop_recognition + boundary_accuracy + "
        "structural_similarity + cognitive_load"
    )
    err_model = smf.ols(err_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Prediction error model ===\n")
    model_text.append(str(err_model.summary()))

    understanding_formula = (
        "system_understanding_score ~ condition + domain + model_completeness + model_coherence + "
        "causal_link_accuracy + feedback_loop_recognition + boundary_accuracy + cognitive_load"
    )
    understanding_model = smf.ols(understanding_formula, data=df).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== System-understanding model ===\n")
    model_text.append(str(understanding_model.summary()))

    success_formula = (
        "problem_success ~ condition + domain + system_understanding_score + prediction_error + "
        "causal_link_accuracy + feedback_loop_recognition + boundary_accuracy + confidence"
    )
    success_model = smf.glm(success_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Problem-success logistic model ===\n")
    model_text.append(str(success_model.summary()))

    intervention_formula = (
        "intervention_choice_accuracy ~ condition + domain + causal_link_accuracy + "
        "feedback_loop_recognition + boundary_accuracy + system_understanding_score + prediction_error"
    )
    intervention_model = smf.glm(intervention_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Intervention-choice logistic model ===\n")
    model_text.append(str(intervention_model.summary()))

    revision_formula = (
        "model_revision_score ~ condition + domain + prediction_error + feedback_loop_recognition + "
        "causal_link_accuracy + model_coherence + cognitive_load"
    )
    revision_model = smf.ols(revision_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Model-revision model ===\n")
    model_text.append(str(revision_model.summary()))

    transfer_formula = (
        "transfer_score ~ condition + domain + structural_similarity + model_coherence + "
        "causal_link_accuracy + boundary_accuracy + system_understanding_score + problem_success"
    )
    transfer_model = smf.ols(transfer_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Transfer model ===\n")
    model_text.append(str(transfer_model.summary()))

    rt_df = df[df["reasoning_time_ms"] >= 150].copy()
    rt_df["log_reasoning_time"] = np.log(rt_df["reasoning_time_ms"])
    rt_formula = (
        "log_reasoning_time ~ condition + domain + model_coherence + cognitive_load + "
        "prediction_error + system_understanding_score + problem_success"
    )
    rt_model = smf.ols(rt_formula, data=rt_df).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Reasoning-time model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": err_model.params.index,
            "prediction_error_coef": err_model.params.values,
            "prediction_error_se": err_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "prediction_error_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/mental_models_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=240)
    parser.add_argument("--trials", type=int, default=12)
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
        default_input = Path("data/mental_models_trials.csv")
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
