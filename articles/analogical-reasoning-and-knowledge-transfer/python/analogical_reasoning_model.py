#!/usr/bin/env python3
"""
Analogical reasoning and knowledge transfer.

This script can:
1. Generate synthetic analogical-reasoning trial data.
2. Estimate models for mapping accuracy, transfer success, inference quality,
   schema abstraction, and response time.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
learning science, AI, education, legal reasoning, and decision-science research.
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


CONDITIONS = ["control", "surface_match", "structure_match", "analogical_cue", "high_complexity", "schema_training"]
SOURCE_IDS = ["S01", "S02", "S03", "S04", "S05"]
TARGET_IDS = ["T01", "T02", "T03", "T04", "T05"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 200,
    trials_per_participant: int = 12,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"surface": 5.0, "structure": 5.2, "complexity": 5.0, "cue": 0, "schema": 4.8},
        "surface_match": {"surface": 8.2, "structure": 4.0, "complexity": 5.6, "cue": 0, "schema": 3.8},
        "structure_match": {"surface": 4.0, "structure": 8.0, "complexity": 6.2, "cue": 0, "schema": 6.8},
        "analogical_cue": {"surface": 4.6, "structure": 7.6, "complexity": 6.4, "cue": 1, "schema": 7.1},
        "high_complexity": {"surface": 4.8, "structure": 7.1, "complexity": 8.7, "cue": 0, "schema": 5.5},
        "schema_training": {"surface": 4.5, "structure": 8.4, "complexity": 6.0, "cue": 1, "schema": 8.4},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        relational_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]

            source_id = rng.choice(SOURCE_IDS)
            target_id = rng.choice(TARGET_IDS)

            source_familiarity = np.clip(rng.normal(6.2 + 0.35 * relational_skill, 1.0), 0, 10)
            target_novelty = np.clip(rng.normal(6.5 if condition != "control" else 5.6, 1.0), 0, 10)
            surface_similarity = np.clip(rng.normal(params["surface"], 0.9), 0, 10)
            structural_similarity = np.clip(rng.normal(params["structure"] + 0.25 * relational_skill, 0.9), 0, 10)
            relational_complexity = np.clip(rng.normal(params["complexity"], 1.0), 0, 10)
            working_memory_load = np.clip(
                rng.normal(3.0 + 0.45 * relational_complexity + 0.20 * target_novelty - 0.20 * relational_skill, 0.9),
                0,
                10,
            )
            analogical_cue = int(params["cue"])

            mapping_logit = (
                -2.1
                + 0.52 * structural_similarity
                + 0.22 * source_familiarity
                + 0.45 * analogical_cue
                - 0.30 * relational_complexity
                - 0.18 * working_memory_load
                - 0.10 * surface_similarity * (1 if condition == "surface_match" else 0)
                + relational_skill
                + rng.normal(0, 0.25)
            )
            mapping_accuracy = int(rng.random() < logistic(np.array([mapping_logit]))[0])

            transfer_logit = (
                -2.5
                + 0.62 * structural_similarity
                + 0.65 * mapping_accuracy
                + 0.35 * analogical_cue
                + 0.18 * source_familiarity
                - 0.26 * relational_complexity
                - 0.18 * working_memory_load
                - 0.08 * target_novelty
                + relational_skill
                + rng.normal(0, 0.25)
            )
            transfer_success = int(rng.random() < logistic(np.array([transfer_logit]))[0])

            schema_abstraction = np.clip(
                rng.normal(
                    params["schema"]
                    + 0.32 * structural_similarity
                    + 0.65 * mapping_accuracy
                    + 0.50 * transfer_success
                    - 0.15 * surface_similarity
                    - 0.10 * relational_complexity,
                    0.9,
                ),
                0,
                10,
            )

            inference_quality = np.clip(
                rng.normal(
                    35
                    + 4.8 * structural_similarity
                    + 8.0 * mapping_accuracy
                    + 9.0 * transfer_success
                    + 2.4 * schema_abstraction
                    - 2.5 * relational_complexity
                    - 1.2 * working_memory_load,
                    7.0,
                ),
                0,
                100,
            )

            confidence = np.clip(
                rng.normal(
                    2.2 + 0.45 * schema_abstraction + 0.035 * inference_quality + 0.45 * transfer_success,
                    0.8,
                ),
                0,
                10,
            )

            log_rt = (
                math.log(3000)
                + 0.060 * relational_complexity
                + 0.040 * working_memory_load
                + 0.030 * target_novelty
                - 0.035 * structural_similarity
                - 0.025 * analogical_cue
                + speed_factor
                + rng.normal(0, 0.13)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 120000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "source_id": source_id,
                    "target_id": target_id,
                    "trial": trial,
                    "source_familiarity": round(float(source_familiarity), 3),
                    "target_novelty": round(float(target_novelty), 3),
                    "surface_similarity": round(float(surface_similarity), 3),
                    "structural_similarity": round(float(structural_similarity), 3),
                    "relational_complexity": round(float(relational_complexity), 3),
                    "working_memory_load": round(float(working_memory_load), 3),
                    "analogical_cue": analogical_cue,
                    "mapping_accuracy": mapping_accuracy,
                    "transfer_success": transfer_success,
                    "inference_quality": round(float(inference_quality), 3),
                    "schema_abstraction": round(float(schema_abstraction), 3),
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
            n_trials=("mapping_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_source_familiarity=("source_familiarity", "mean"),
            mean_target_novelty=("target_novelty", "mean"),
            mean_surface_similarity=("surface_similarity", "mean"),
            mean_structural_similarity=("structural_similarity", "mean"),
            mean_relational_complexity=("relational_complexity", "mean"),
            mean_working_memory_load=("working_memory_load", "mean"),
            analogical_cue_rate=("analogical_cue", "mean"),
            mapping_accuracy_rate=("mapping_accuracy", "mean"),
            transfer_success_rate=("transfer_success", "mean"),
            mean_inference_quality=("inference_quality", "mean"),
            mean_schema_abstraction=("schema_abstraction", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_target = (
        df.groupby("target_id")
        .agg(
            n_trials=("mapping_accuracy", "size"),
            mean_target_novelty=("target_novelty", "mean"),
            mapping_accuracy_rate=("mapping_accuracy", "mean"),
            transfer_success_rate=("transfer_success", "mean"),
            mean_inference_quality=("inference_quality", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_target.to_csv(outputs / "summary_by_target.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    mapping_formula = (
        "mapping_accuracy ~ condition + source_familiarity + target_novelty + "
        "surface_similarity + structural_similarity + relational_complexity + "
        "working_memory_load + analogical_cue"
    )

    mapping_model = smf.glm(
        mapping_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Mapping-accuracy model: logistic GLM ===\n")
    model_text.append(str(mapping_model.summary()))

    transfer_formula = (
        "transfer_success ~ condition + source_familiarity + target_novelty + "
        "surface_similarity + structural_similarity + relational_complexity + "
        "working_memory_load + analogical_cue + mapping_accuracy"
    )

    transfer_model = smf.glm(
        transfer_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Transfer-success model: logistic GLM ===\n")
    model_text.append(str(transfer_model.summary()))

    quality_formula = (
        "inference_quality ~ condition + structural_similarity + surface_similarity + "
        "relational_complexity + working_memory_load + mapping_accuracy + "
        "transfer_success + schema_abstraction"
    )

    quality_model = smf.ols(quality_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Inference-quality model: cluster-robust OLS ===\n")
    model_text.append(str(quality_model.summary()))

    schema_formula = (
        "schema_abstraction ~ condition + source_familiarity + structural_similarity + "
        "surface_similarity + mapping_accuracy + transfer_success + relational_complexity"
    )

    schema_model = smf.ols(schema_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Schema-abstraction model ===\n")
    model_text.append(str(schema_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ condition + relational_complexity + working_memory_load + "
        "source_familiarity + target_novelty + structural_similarity + analogical_cue"
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
            "term": mapping_model.params.index,
            "mapping_coef": mapping_model.params.values,
            "mapping_se": mapping_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "mapping_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/analogical_reasoning_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=200)
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
        default_input = Path("data/analogical_reasoning_trials.csv")
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
