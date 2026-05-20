#!/usr/bin/env python3
"""
Language processing in cognitive psychology.

This script can:
1. Generate synthetic language-processing trial data.
2. Estimate models for comprehension accuracy, lexical decision accuracy,
   production accuracy, reading time, lexical decision RT, and production latency.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
psycholinguistics, literacy research, cognitive neuroscience, AI, and HCI.
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
    "high_frequency",
    "low_frequency",
    "syntactic_complexity",
    "semantic_prime",
    "pragmatic_inference",
    "discourse_context",
    "production_load",
]

MODALITIES = ["speech", "reading", "writing", "lexical_decision"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 220,
    trials_per_participant: int = 16,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"freq": 6.0, "amb": 3.5, "syntax": 4.2, "pred": 5.4, "context": 5.5, "wm": 4.6, "prag": 3.4, "disc": 6.0},
        "high_frequency": {"freq": 8.7, "amb": 2.6, "syntax": 3.4, "pred": 7.2, "context": 6.8, "wm": 3.2, "prag": 2.8, "disc": 7.0},
        "low_frequency": {"freq": 2.4, "amb": 4.2, "syntax": 4.6, "pred": 4.0, "context": 4.6, "wm": 5.2, "prag": 3.2, "disc": 5.0},
        "syntactic_complexity": {"freq": 5.4, "amb": 4.8, "syntax": 8.3, "pred": 4.2, "context": 4.8, "wm": 7.8, "prag": 4.4, "disc": 4.8},
        "semantic_prime": {"freq": 7.2, "amb": 3.0, "syntax": 3.8, "pred": 8.5, "context": 8.0, "wm": 3.6, "prag": 3.0, "disc": 8.0},
        "pragmatic_inference": {"freq": 6.0, "amb": 5.2, "syntax": 5.6, "pred": 5.0, "context": 6.5, "wm": 6.1, "prag": 8.4, "disc": 6.1},
        "discourse_context": {"freq": 6.5, "amb": 4.0, "syntax": 5.0, "pred": 7.4, "context": 8.6, "wm": 4.7, "prag": 5.0, "disc": 8.6},
        "production_load": {"freq": 5.7, "amb": 4.8, "syntax": 6.7, "pred": 5.2, "context": 5.8, "wm": 7.8, "prag": 5.4, "disc": 5.8},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        language_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]
            modality = rng.choice(MODALITIES, p=[0.28, 0.38, 0.12, 0.22])
            item_id = f"LP{trial:03d}_{participant}"

            word_frequency = np.clip(rng.normal(params["freq"] + 0.18 * language_skill, 0.9), 0, 10)
            lexical_ambiguity = np.clip(rng.normal(params["amb"], 0.9), 0, 10)
            syntactic_complexity = np.clip(rng.normal(params["syntax"], 0.9), 0, 10)
            semantic_predictability = np.clip(rng.normal(params["pred"] + 0.15 * language_skill, 0.9), 0, 10)
            context_support = np.clip(rng.normal(params["context"], 0.9), 0, 10)
            working_memory_load = np.clip(rng.normal(params["wm"] + 0.20 * syntactic_complexity - 0.12 * context_support, 0.9), 0, 10)
            pragmatic_inference_demand = np.clip(rng.normal(params["prag"], 0.9), 0, 10)
            discourse_coherence = np.clip(rng.normal(params["disc"] + 0.15 * context_support, 0.9), 0, 10)

            comp_logit = (
                -1.0
                + 0.22 * word_frequency
                - 0.24 * lexical_ambiguity
                - 0.30 * syntactic_complexity
                + 0.24 * semantic_predictability
                + 0.20 * context_support
                - 0.24 * working_memory_load
                - 0.18 * pragmatic_inference_demand
                + 0.25 * discourse_coherence
                + 0.80 * language_skill
                + rng.normal(0, 0.30)
            )
            comprehension_accuracy = int(rng.random() < logistic(np.array([comp_logit]))[0])

            lex_logit = (
                -0.6
                + 0.34 * word_frequency
                - 0.18 * lexical_ambiguity
                + 0.16 * semantic_predictability
                - 0.12 * working_memory_load
                + 0.65 * language_skill
                + rng.normal(0, 0.28)
            )
            lexical_decision_accuracy = int(rng.random() < logistic(np.array([lex_logit]))[0])

            prod_logit = (
                -0.8
                + 0.22 * word_frequency
                - 0.20 * lexical_ambiguity
                - 0.20 * syntactic_complexity
                + 0.18 * context_support
                - 0.30 * working_memory_load
                - 0.18 * pragmatic_inference_demand
                + 0.18 * discourse_coherence
                + 0.70 * language_skill
                + rng.normal(0, 0.30)
            )
            production_accuracy = int(rng.random() < logistic(np.array([prod_logit]))[0])

            log_read = (
                math.log(1200)
                - 0.045 * word_frequency
                + 0.060 * lexical_ambiguity
                + 0.080 * syntactic_complexity
                - 0.045 * semantic_predictability
                - 0.030 * context_support
                + 0.065 * working_memory_load
                + 0.025 * pragmatic_inference_demand
                - 0.025 * comprehension_accuracy
                + speed_factor
                + rng.normal(0, 0.13)
            )
            reading_time_ms = int(np.clip(np.exp(log_read), 100, 90000))

            log_lex = (
                math.log(650)
                - 0.055 * word_frequency
                + 0.040 * lexical_ambiguity
                - 0.035 * semantic_predictability
                + 0.035 * working_memory_load
                - 0.030 * lexical_decision_accuracy
                + speed_factor
                + rng.normal(0, 0.12)
            )
            lexical_decision_rt_ms = int(np.clip(np.exp(log_lex), 100, 60000))

            log_prod = (
                math.log(1800)
                - 0.035 * word_frequency
                + 0.040 * lexical_ambiguity
                + 0.055 * syntactic_complexity
                - 0.025 * context_support
                + 0.070 * working_memory_load
                + 0.050 * pragmatic_inference_demand
                - 0.025 * production_accuracy
                + speed_factor
                + rng.normal(0, 0.14)
            )
            production_latency_ms = int(np.clip(np.exp(log_prod), 100, 90000))

            confidence = np.clip(
                rng.normal(
                    2.0
                    + 0.55 * comprehension_accuracy
                    + 0.40 * lexical_decision_accuracy
                    + 0.35 * production_accuracy
                    + 0.20 * discourse_coherence
                    + 0.15 * semantic_predictability
                    - 0.12 * working_memory_load,
                    0.8,
                ),
                0,
                10,
            )

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "trial": trial,
                    "item_id": item_id,
                    "modality": modality,
                    "word_frequency": round(float(word_frequency), 3),
                    "lexical_ambiguity": round(float(lexical_ambiguity), 3),
                    "syntactic_complexity": round(float(syntactic_complexity), 3),
                    "semantic_predictability": round(float(semantic_predictability), 3),
                    "context_support": round(float(context_support), 3),
                    "working_memory_load": round(float(working_memory_load), 3),
                    "pragmatic_inference_demand": round(float(pragmatic_inference_demand), 3),
                    "discourse_coherence": round(float(discourse_coherence), 3),
                    "comprehension_accuracy": comprehension_accuracy,
                    "lexical_decision_accuracy": lexical_decision_accuracy,
                    "production_accuracy": production_accuracy,
                    "reading_time_ms": reading_time_ms,
                    "lexical_decision_rt_ms": lexical_decision_rt_ms,
                    "production_latency_ms": production_latency_ms,
                    "confidence": round(float(confidence), 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("comprehension_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_word_frequency=("word_frequency", "mean"),
            mean_lexical_ambiguity=("lexical_ambiguity", "mean"),
            mean_syntactic_complexity=("syntactic_complexity", "mean"),
            mean_semantic_predictability=("semantic_predictability", "mean"),
            mean_context_support=("context_support", "mean"),
            mean_working_memory_load=("working_memory_load", "mean"),
            mean_pragmatic_demand=("pragmatic_inference_demand", "mean"),
            mean_discourse_coherence=("discourse_coherence", "mean"),
            comprehension_accuracy_rate=("comprehension_accuracy", "mean"),
            lexical_decision_accuracy_rate=("lexical_decision_accuracy", "mean"),
            production_accuracy_rate=("production_accuracy", "mean"),
            mean_reading_time_ms=("reading_time_ms", "mean"),
            mean_lexical_decision_rt_ms=("lexical_decision_rt_ms", "mean"),
            mean_production_latency_ms=("production_latency_ms", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_modality = (
        df.groupby("modality")
        .agg(
            n_trials=("comprehension_accuracy", "size"),
            comprehension_accuracy_rate=("comprehension_accuracy", "mean"),
            mean_working_memory_load=("working_memory_load", "mean"),
            mean_reading_time_ms=("reading_time_ms", "mean"),
            mean_lexical_decision_rt_ms=("lexical_decision_rt_ms", "mean"),
            mean_production_latency_ms=("production_latency_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_modality.to_csv(outputs / "summary_by_modality.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    comp_formula = (
        "comprehension_accuracy ~ condition + modality + word_frequency + lexical_ambiguity + "
        "syntactic_complexity + semantic_predictability + context_support + "
        "working_memory_load + pragmatic_inference_demand + discourse_coherence"
    )

    comp_model = smf.glm(
        comp_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Comprehension accuracy: logistic GLM ===\n")
    model_text.append(str(comp_model.summary()))

    lex_formula = (
        "lexical_decision_accuracy ~ condition + word_frequency + lexical_ambiguity + "
        "semantic_predictability + working_memory_load"
    )

    lex_model = smf.glm(
        lex_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Lexical decision accuracy: logistic GLM ===\n")
    model_text.append(str(lex_model.summary()))

    prod_formula = (
        "production_accuracy ~ condition + modality + word_frequency + lexical_ambiguity + "
        "syntactic_complexity + context_support + working_memory_load + "
        "pragmatic_inference_demand + discourse_coherence"
    )

    prod_model = smf.glm(
        prod_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Production accuracy: logistic GLM ===\n")
    model_text.append(str(prod_model.summary()))

    read_df = df[df["reading_time_ms"] >= 100].copy()
    read_df["log_reading_time"] = np.log(read_df["reading_time_ms"])

    read_formula = (
        "log_reading_time ~ condition + modality + word_frequency + lexical_ambiguity + "
        "syntactic_complexity + semantic_predictability + context_support + "
        "working_memory_load + pragmatic_inference_demand + comprehension_accuracy"
    )

    read_model = smf.ols(read_formula, data=read_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": read_df["participant"]},
    )
    model_text.append("\n\n=== Reading time: log RT model ===\n")
    model_text.append(str(read_model.summary()))

    lexrt_df = df[df["lexical_decision_rt_ms"] >= 100].copy()
    lexrt_df["log_lexical_decision_rt"] = np.log(lexrt_df["lexical_decision_rt_ms"])

    lexrt_formula = (
        "log_lexical_decision_rt ~ condition + word_frequency + lexical_ambiguity + "
        "semantic_predictability + working_memory_load + lexical_decision_accuracy"
    )

    lexrt_model = smf.ols(lexrt_formula, data=lexrt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": lexrt_df["participant"]},
    )
    model_text.append("\n\n=== Lexical decision RT: log RT model ===\n")
    model_text.append(str(lexrt_model.summary()))

    prodlat_df = df[df["production_latency_ms"] >= 100].copy()
    prodlat_df["log_production_latency"] = np.log(prodlat_df["production_latency_ms"])

    prodlat_formula = (
        "log_production_latency ~ condition + modality + word_frequency + lexical_ambiguity + "
        "syntactic_complexity + context_support + working_memory_load + "
        "pragmatic_inference_demand + production_accuracy"
    )

    prodlat_model = smf.ols(prodlat_formula, data=prodlat_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": prodlat_df["participant"]},
    )
    model_text.append("\n\n=== Production latency: log RT model ===\n")
    model_text.append(str(prodlat_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": comp_model.params.index,
            "comprehension_coef": comp_model.params.values,
            "comprehension_se": comp_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "comprehension_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/language_processing_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=220)
    parser.add_argument("--trials", type=int, default=16)
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
        default_input = Path("data/language_processing_trials.csv")
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
