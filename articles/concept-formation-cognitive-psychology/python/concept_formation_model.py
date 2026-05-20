#!/usr/bin/env python3
"""
Concept formation in cognitive psychology.

This script can:
1. Generate synthetic concept-formation and categorization trial data.
2. Estimate models for category accuracy, generalization, discrimination,
   abstraction quality, conceptual flexibility, and response time.
3. Compare prototype-like and exemplar-like classification signals.
4. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
learning science, psycholinguistics, AI, education, and category-learning research.
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
    "prototype_training",
    "exemplar_training",
    "rule_training",
    "feedback_learning",
    "boundary_ambiguity",
    "conceptual_shift",
]

CATEGORIES = ["Category_A", "Category_B", "Category_C"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 220,
    trials_per_participant: int = 14,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"prototype": 3.4, "exemplar": 6.0, "feature": 5.8, "boundary": 4.4, "rule": 5.6, "feedback": 0, "flex": 5.8},
        "prototype_training": {"prototype": 1.8, "exemplar": 6.8, "feature": 7.4, "boundary": 2.2, "rule": 6.5, "feedback": 1, "flex": 6.5},
        "exemplar_training": {"prototype": 3.0, "exemplar": 8.2, "feature": 6.6, "boundary": 3.0, "rule": 5.8, "feedback": 1, "flex": 6.8},
        "rule_training": {"prototype": 3.2, "exemplar": 6.0, "feature": 7.8, "boundary": 2.8, "rule": 8.5, "feedback": 1, "flex": 6.2},
        "feedback_learning": {"prototype": 2.8, "exemplar": 6.6, "feature": 7.0, "boundary": 3.4, "rule": 6.8, "feedback": 1, "flex": 7.4},
        "boundary_ambiguity": {"prototype": 5.5, "exemplar": 5.0, "feature": 4.8, "boundary": 8.4, "rule": 4.6, "feedback": 0, "flex": 4.8},
        "conceptual_shift": {"prototype": 4.4, "exemplar": 5.7, "feature": 5.8, "boundary": 6.2, "rule": 5.0, "feedback": 1, "flex": 8.1},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        learning_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]
            category_label = rng.choice(CATEGORIES)
            stimulus_id = f"S{trial:03d}_{participant}"

            prototype_distance = np.clip(rng.normal(params["prototype"] - 0.25 * learning_skill, 0.9), 0, 10)
            nearest_competing_distance = np.clip(rng.normal(6.2 - 0.18 * params["boundary"], 0.9), 0, 10)
            exemplar_similarity = np.clip(rng.normal(params["exemplar"] + 0.20 * learning_skill, 0.9), 0, 10)
            feature_diagnosticity = np.clip(rng.normal(params["feature"] + 0.22 * learning_skill, 0.9), 0, 10)
            feature_overlap = np.clip(rng.normal(5.0 + 0.45 * exemplar_similarity - 0.22 * prototype_distance, 0.9), 0, 10)
            boundary_ambiguity = np.clip(rng.normal(params["boundary"], 1.0), 0, 10)
            rule_consistency = np.clip(rng.normal(params["rule"] + 0.16 * learning_skill, 0.9), 0, 10)
            feedback_available = int(params["feedback"])

            accuracy_logit = (
                -1.1
                - 0.28 * prototype_distance
                + 0.16 * nearest_competing_distance
                + 0.24 * exemplar_similarity
                + 0.26 * feature_diagnosticity
                + 0.18 * rule_consistency
                + 0.22 * feedback_available
                - 0.30 * boundary_ambiguity
                + 0.75 * learning_skill
                + rng.normal(0, 0.30)
            )
            category_accuracy = int(rng.random() < logistic(np.array([accuracy_logit]))[0])

            abstraction_quality = np.clip(
                rng.normal(
                    1.5
                    + 0.25 * feature_diagnosticity
                    + 0.22 * rule_consistency
                    + 0.22 * feedback_available
                    + 0.20 * category_accuracy
                    - 0.15 * boundary_ambiguity
                    - 0.10 * prototype_distance
                    + 0.20 * learning_skill,
                    0.8,
                ),
                0,
                10,
            )

            conceptual_flexibility = np.clip(
                rng.normal(
                    params["flex"]
                    + 0.20 * abstraction_quality
                    + 0.25 * feedback_available
                    - 0.12 * boundary_ambiguity,
                    0.9,
                ),
                0,
                10,
            )

            generalization_score = np.clip(
                rng.normal(
                    35
                    + 4.4 * abstraction_quality
                    + 2.0 * feature_diagnosticity
                    + 2.4 * conceptual_flexibility
                    + 5.0 * category_accuracy
                    - 1.8 * prototype_distance
                    - 1.2 * boundary_ambiguity,
                    7.0,
                ),
                0,
                100,
            )

            discrimination_score = np.clip(
                rng.normal(
                    35
                    + 3.4 * feature_diagnosticity
                    + 2.5 * nearest_competing_distance
                    + 1.8 * rule_consistency
                    + 4.5 * category_accuracy
                    - 2.5 * boundary_ambiguity
                    - 0.8 * prototype_distance,
                    7.0,
                ),
                0,
                100,
            )

            confidence = np.clip(
                rng.normal(
                    2.0
                    + 0.45 * category_accuracy
                    + 0.035 * generalization_score
                    + 0.20 * abstraction_quality
                    - 0.12 * boundary_ambiguity,
                    0.8,
                ),
                0,
                10,
            )

            log_rt = (
                math.log(1400)
                + 0.065 * prototype_distance
                + 0.060 * boundary_ambiguity
                - 0.030 * exemplar_similarity
                - 0.030 * feature_diagnosticity
                - 0.025 * rule_consistency
                - 0.030 * category_accuracy
                + speed_factor
                + rng.normal(0, 0.13)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 60000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "trial": trial,
                    "stimulus_id": stimulus_id,
                    "category_label": category_label,
                    "prototype_distance": round(float(prototype_distance), 3),
                    "nearest_competing_distance": round(float(nearest_competing_distance), 3),
                    "exemplar_similarity": round(float(exemplar_similarity), 3),
                    "feature_diagnosticity": round(float(feature_diagnosticity), 3),
                    "feature_overlap": round(float(feature_overlap), 3),
                    "boundary_ambiguity": round(float(boundary_ambiguity), 3),
                    "rule_consistency": round(float(rule_consistency), 3),
                    "feedback_available": feedback_available,
                    "category_accuracy": category_accuracy,
                    "generalization_score": round(float(generalization_score), 3),
                    "discrimination_score": round(float(discrimination_score), 3),
                    "abstraction_quality": round(float(abstraction_quality), 3),
                    "conceptual_flexibility": round(float(conceptual_flexibility), 3),
                    "confidence": round(float(confidence), 3),
                    "response_time_ms": response_time_ms,
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("category_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_prototype_distance=("prototype_distance", "mean"),
            mean_competing_distance=("nearest_competing_distance", "mean"),
            mean_exemplar_similarity=("exemplar_similarity", "mean"),
            mean_feature_diagnosticity=("feature_diagnosticity", "mean"),
            mean_boundary_ambiguity=("boundary_ambiguity", "mean"),
            mean_rule_consistency=("rule_consistency", "mean"),
            feedback_rate=("feedback_available", "mean"),
            accuracy_rate=("category_accuracy", "mean"),
            mean_generalization=("generalization_score", "mean"),
            mean_discrimination=("discrimination_score", "mean"),
            mean_abstraction_quality=("abstraction_quality", "mean"),
            mean_conceptual_flexibility=("conceptual_flexibility", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_category = (
        df.groupby("category_label")
        .agg(
            n_trials=("category_accuracy", "size"),
            accuracy_rate=("category_accuracy", "mean"),
            mean_generalization=("generalization_score", "mean"),
            mean_discrimination=("discrimination_score", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_category.to_csv(outputs / "summary_by_category.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    accuracy_formula = (
        "category_accuracy ~ condition + category_label + prototype_distance + "
        "nearest_competing_distance + exemplar_similarity + feature_diagnosticity + "
        "feature_overlap + boundary_ambiguity + rule_consistency + feedback_available"
    )

    accuracy_model = smf.glm(
        accuracy_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Categorization accuracy: logistic GLM ===\n")
    model_text.append(str(accuracy_model.summary()))

    gen_formula = (
        "generalization_score ~ condition + prototype_distance + exemplar_similarity + "
        "feature_diagnosticity + boundary_ambiguity + rule_consistency + "
        "category_accuracy + abstraction_quality + conceptual_flexibility"
    )

    gen_model = smf.ols(gen_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Generalization model ===\n")
    model_text.append(str(gen_model.summary()))

    disc_formula = (
        "discrimination_score ~ condition + prototype_distance + nearest_competing_distance + "
        "feature_diagnosticity + boundary_ambiguity + rule_consistency + category_accuracy"
    )

    disc_model = smf.ols(disc_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Category discrimination model ===\n")
    model_text.append(str(disc_model.summary()))

    abstraction_formula = (
        "abstraction_quality ~ condition + feature_diagnosticity + rule_consistency + "
        "feedback_available + category_accuracy + boundary_ambiguity + prototype_distance"
    )

    abstraction_model = smf.ols(abstraction_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Abstraction quality model ===\n")
    model_text.append(str(abstraction_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ condition + prototype_distance + boundary_ambiguity + "
        "exemplar_similarity + feature_diagnosticity + rule_consistency + category_accuracy"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Response-time model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": accuracy_model.params.index,
            "accuracy_coef": accuracy_model.params.values,
            "accuracy_se": accuracy_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "accuracy_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/concept_formation_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=220)
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
        default_input = Path("data/concept_formation_trials.csv")
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
