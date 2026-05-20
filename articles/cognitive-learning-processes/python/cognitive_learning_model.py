#!/usr/bin/env python3
"""
Cognitive learning processes research model.

This script can:
1. Generate synthetic cognitive-learning trial data.
2. Estimate models for comprehension, accuracy, transfer, retention,
   learning gain, cognitive load, and adaptive application.
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
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False


CONDITIONS = [
    "control", "retrieval_practice", "worked_example", "spaced_practice",
    "interleaving", "high_load", "feedback_rich", "ai_supported"
]
DOMAINS = ["biology", "mathematics", "programming", "history", "systems_thinking", "language", "decision_making"]


def generate_dataset(n_participants: int = 240, sessions: int = 6, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    effects: Dict[str, Dict[str, float]] = {
        "control": {"encoding": 5.4, "load": 6.4, "schema": 4.8, "retrieval": 0, "feedback": 4.8, "support": 0.0},
        "retrieval_practice": {"encoding": 6.8, "load": 5.6, "schema": 6.2, "retrieval": 1, "feedback": 6.4, "support": 0.5},
        "worked_example": {"encoding": 7.2, "load": 4.8, "schema": 6.6, "retrieval": 0, "feedback": 7.0, "support": 0.7},
        "spaced_practice": {"encoding": 7.4, "load": 5.2, "schema": 6.8, "retrieval": 1, "feedback": 6.6, "support": 0.8},
        "interleaving": {"encoding": 7.0, "load": 5.8, "schema": 7.0, "retrieval": 1, "feedback": 6.8, "support": 0.8},
        "high_load": {"encoding": 5.2, "load": 8.4, "schema": 5.0, "retrieval": 0, "feedback": 4.8, "support": -0.5},
        "feedback_rich": {"encoding": 7.4, "load": 5.4, "schema": 6.8, "retrieval": 1, "feedback": 8.6, "support": 0.9},
        "ai_supported": {"encoding": 7.1, "load": 5.0, "schema": 6.7, "retrieval": 1, "feedback": 7.8, "support": 0.7},
    }

    for p_idx in range(1, n_participants + 1):
        participant = f"P{p_idx:03d}"
        ability = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.14)
        domain = rng.choice(DOMAINS)

        for session in range(1, sessions + 1):
            condition = rng.choice(CONDITIONS)
            e = effects[condition]
            item_id = f"CL{session:03d}_{participant}"

            prior_knowledge = np.clip(rng.normal(4.8 + 0.30 * ability + 0.22 * session, 1.1), 0, 10)
            attention_score = np.clip(rng.normal(6.2 + 0.20 * ability + 0.12 * e["support"], 1.0), 0, 10)
            encoding_quality = np.clip(rng.normal(e["encoding"] + 0.25 * prior_knowledge + 0.18 * attention_score + 0.15 * ability, 0.9), 0, 10)
            working_memory_load = np.clip(rng.normal(e["load"] - 0.18 * prior_knowledge - 0.10 * encoding_quality, 0.9), 0, 10)
            schema_strength = np.clip(rng.normal(e["schema"] + 0.22 * session + 0.20 * prior_knowledge + 0.18 * encoding_quality, 0.9), 0, 10)
            retrieval_practice = int(e["retrieval"])
            feedback_quality = np.clip(rng.normal(e["feedback"], 0.9), 0, 10)
            cognitive_load = np.clip(rng.normal(e["load"] + 0.25 * working_memory_load - 0.20 * schema_strength - 0.10 * feedback_quality, 0.9), 0, 10)

            comprehension_score = np.clip(
                rng.normal(
                    22 + 2.8 * prior_knowledge + 3.0 * attention_score + 3.4 * encoding_quality
                    + 2.8 * schema_strength + 1.8 * feedback_quality + 4.0 * retrieval_practice
                    - 2.4 * cognitive_load - 1.6 * working_memory_load,
                    6.0,
                ),
                0, 100,
            )
            accuracy = np.clip(rng.normal(0.25 + 0.006 * comprehension_score + 0.025 * schema_strength - 0.015 * cognitive_load, 0.07), 0, 1)
            transfer_score = np.clip(
                rng.normal(
                    20 + 0.45 * comprehension_score + 2.4 * schema_strength + 2.0 * retrieval_practice
                    + 1.8 * feedback_quality - 1.8 * cognitive_load + 3.0 * (condition == "interleaving"),
                    6.5,
                ),
                0, 100,
            )
            retention_score = np.clip(
                rng.normal(
                    24 + 0.40 * comprehension_score + 3.4 * retrieval_practice
                    + 2.2 * (condition == "spaced_practice") + 1.6 * schema_strength
                    - 1.2 * cognitive_load,
                    6.0,
                ),
                0, 100,
            )
            learning_gain = np.clip(
                rng.normal(
                    -10 + 0.30 * comprehension_score + 1.8 * feedback_quality
                    + 2.6 * retrieval_practice - 1.4 * cognitive_load,
                    5.0,
                ),
                -100, 100,
            )
            adaptive_application = np.clip(
                rng.normal(
                    1.8 + 0.055 * transfer_score + 0.20 * schema_strength
                    + 0.14 * feedback_quality - 0.12 * cognitive_load,
                    0.8,
                ),
                0, 10,
            )

            log_rt = (
                math.log(2600)
                - 0.06 * session
                - 0.020 * comprehension_score
                - 0.050 * schema_strength
                + 0.065 * cognitive_load
                + 0.045 * working_memory_load
                + speed_factor
                + rng.normal(0, 0.12)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 120000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "session": session,
                    "item_id": item_id,
                    "prior_knowledge": round(float(prior_knowledge), 3),
                    "attention_score": round(float(attention_score), 3),
                    "encoding_quality": round(float(encoding_quality), 3),
                    "working_memory_load": round(float(working_memory_load), 3),
                    "schema_strength": round(float(schema_strength), 3),
                    "retrieval_practice": retrieval_practice,
                    "feedback_quality": round(float(feedback_quality), 3),
                    "cognitive_load": round(float(cognitive_load), 3),
                    "comprehension_score": round(float(comprehension_score), 3),
                    "accuracy": round(float(accuracy), 3),
                    "transfer_score": round(float(transfer_score), 3),
                    "retention_score": round(float(retention_score), 3),
                    "response_time_ms": response_time_ms,
                    "learning_gain": round(float(learning_gain), 3),
                    "adaptive_application": round(float(adaptive_application), 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("accuracy", "size"),
            participants=("participant", "nunique"),
            mean_prior_knowledge=("prior_knowledge", "mean"),
            mean_attention=("attention_score", "mean"),
            mean_encoding=("encoding_quality", "mean"),
            mean_schema_strength=("schema_strength", "mean"),
            retrieval_rate=("retrieval_practice", "mean"),
            mean_feedback=("feedback_quality", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_comprehension=("comprehension_score", "mean"),
            mean_accuracy=("accuracy", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_retention=("retention_score", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_learning_gain=("learning_gain", "mean"),
            mean_adaptive_application=("adaptive_application", "mean"),
        )
        .reset_index()
    )

    by_session = (
        df.groupby(["condition", "session"])
        .agg(
            mean_accuracy=("accuracy", "mean"),
            mean_comprehension=("comprehension_score", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_retention=("retention_score", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_session.to_csv(outputs / "learning_curve_by_session.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    formulas = {
        "comprehension_model": (
            "comprehension_score ~ session * condition + domain + prior_knowledge + attention_score + "
            "encoding_quality + working_memory_load + schema_strength + retrieval_practice + "
            "feedback_quality + cognitive_load"
        ),
        "accuracy_model": (
            "accuracy ~ session * condition + domain + prior_knowledge + attention_score + "
            "encoding_quality + schema_strength + retrieval_practice + feedback_quality + cognitive_load"
        ),
        "transfer_model": (
            "transfer_score ~ session * condition + domain + prior_knowledge + schema_strength + "
            "retrieval_practice + feedback_quality + comprehension_score + cognitive_load"
        ),
        "retention_model": (
            "retention_score ~ session * condition + domain + retrieval_practice + feedback_quality + "
            "schema_strength + comprehension_score + cognitive_load"
        ),
        "learning_gain_model": (
            "learning_gain ~ session * condition + domain + prior_knowledge + attention_score + "
            "encoding_quality + retrieval_practice + feedback_quality + cognitive_load"
        ),
        "adaptive_application_model": (
            "adaptive_application ~ session + condition + domain + schema_strength + transfer_score + "
            "feedback_quality + retrieval_practice + cognitive_load"
        ),
    }

    fitted = {}
    for name, formula in formulas.items():
        model = smf.ols(formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
        fitted[name] = model
        model_text.append(f"\n\n=== {name} ===\n")
        model_text.append(str(model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])
    rt_model = smf.ols(
        "log_response_time ~ session * condition + domain + comprehension_score + "
        "schema_strength + cognitive_load + working_memory_load + accuracy",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== response_time_model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": fitted["comprehension_model"].params.index,
            "comprehension_coef": fitted["comprehension_model"].params.values,
            "comprehension_se": fitted["comprehension_model"].bse.values,
        }
    )
    coefficients.to_csv(outputs / "comprehension_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/cognitive_learning_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=240)
    parser.add_argument("--sessions", type=int, default=6)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = generate_dataset(n_participants=args.participants, sessions=args.sessions, seed=args.seed)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default_input = Path("data/cognitive_learning_trials.csv")
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
