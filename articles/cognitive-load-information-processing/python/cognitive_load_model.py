#!/usr/bin/env python3
"""
Cognitive load research model.

This script can:
1. Generate synthetic cognitive-load trial data.
2. Estimate models for accuracy, correct response, response time, subjective effort,
   transfer, learning gain, and mental efficiency.
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
    from scipy.optimize import curve_fit
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False


CONDITIONS = [
    "worked_example",
    "problem_solving",
    "split_attention",
    "integrated_design",
    "redundant",
    "coherence",
    "signaling",
    "ai_assisted",
    "control",
]

DOMAINS = ["math", "science", "medicine", "interface", "policy", "engineering", "finance", "ai"]
EXPERTISE = ["novice", "intermediate", "advanced", "expert"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def load_decline(total_load: np.ndarray, a: float, b: float, c: float) -> np.ndarray:
    return a / (1.0 + np.exp(b * (total_load - c)))


def generate_dataset(n_participants: int = 260, trials_per_participant: int = 14, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "worked_example": {"extraneous": -2.2, "germane": 1.2, "design": 2.0, "split": -1.4, "redundancy": -0.8, "ai": 0.0},
        "problem_solving": {"extraneous": 1.8, "germane": -0.8, "design": -1.0, "split": 0.8, "redundancy": 0.2, "ai": 0.0},
        "split_attention": {"extraneous": 2.4, "germane": -0.4, "design": -1.8, "split": 2.8, "redundancy": 0.4, "ai": 0.0},
        "integrated_design": {"extraneous": -2.0, "germane": 1.0, "design": 2.4, "split": -2.0, "redundancy": -0.5, "ai": 0.0},
        "redundant": {"extraneous": 1.6, "germane": -0.5, "design": -0.8, "split": 0.2, "redundancy": 2.6, "ai": 0.0},
        "coherence": {"extraneous": -1.6, "germane": 1.0, "design": 2.0, "split": -0.8, "redundancy": -1.4, "ai": 0.0},
        "signaling": {"extraneous": -1.2, "germane": 0.9, "design": 2.0, "split": -0.6, "redundancy": -0.5, "ai": 0.0},
        "ai_assisted": {"extraneous": -0.8, "germane": 0.4, "design": 1.0, "split": -0.4, "redundancy": 0.2, "ai": 1.0},
        "control": {"extraneous": 0.0, "germane": 0.0, "design": 0.0, "split": 0.0, "redundancy": 0.0, "ai": 0.0},
    }

    expertise_prior = {"novice": 2.6, "intermediate": 5.2, "advanced": 7.0, "expert": 8.4}

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        expertise_level = rng.choice(EXPERTISE, p=[0.34, 0.33, 0.21, 0.12])
        base_prior = expertise_prior[expertise_level] + rng.normal(0, 0.65)
        capacity = np.clip(rng.normal(6.0 + 0.18 * base_prior, 0.85), 2.0, 10.0)
        speed_factor = rng.normal(0, 0.15)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            ce = condition_effects[condition]
            task_id = f"CL{trial:03d}_{participant}"

            element_interactivity = np.clip(rng.normal(6.0 + (domain in ["medicine", "engineering", "ai"]) * 0.8, 1.2), 0, 10)
            intrinsic_load = np.clip(rng.normal(2.0 + 0.72 * element_interactivity - 0.18 * base_prior, 0.9), 0, 10)
            split_attention = np.clip(rng.normal(3.2 + ce["split"], 1.0), 0, 10)
            redundancy = np.clip(rng.normal(3.0 + ce["redundancy"], 1.0), 0, 10)
            design_quality = np.clip(rng.normal(5.6 + ce["design"], 1.1), 0, 10)
            extraneous_load = np.clip(
                rng.normal(3.2 + ce["extraneous"] + 0.35 * split_attention + 0.24 * redundancy - 0.32 * design_quality, 0.9),
                0,
                10,
            )
            germane_load = np.clip(
                rng.normal(4.8 + ce["germane"] + 0.18 * design_quality + 0.15 * base_prior - 0.14 * extraneous_load, 0.9),
                0,
                10,
            )
            prior_knowledge = np.clip(rng.normal(base_prior, 0.7), 0, 10)
            working_memory_capacity = np.clip(rng.normal(capacity, 0.55), 0, 10)

            total_load = intrinsic_load + extraneous_load + 0.55 * germane_load
            productive_load = germane_load - 0.35 * extraneous_load
            overload_margin = working_memory_capacity + 0.45 * prior_knowledge - total_load

            subjective_effort = np.clip(
                rng.normal(4.0 + 0.32 * intrinsic_load + 0.46 * extraneous_load + 0.18 * germane_load - 0.22 * prior_knowledge, 0.8),
                0,
                10,
            )
            mental_demand = np.clip(rng.normal(3.8 + 0.42 * intrinsic_load + 0.36 * extraneous_load - 0.12 * prior_knowledge, 0.9), 0, 10)
            temporal_demand = np.clip(rng.normal(3.2 + 0.22 * intrinsic_load + 0.22 * extraneous_load + 0.18 * ce["ai"], 1.0), 0, 10)
            frustration = np.clip(rng.normal(2.6 + 0.46 * extraneous_load - 0.18 * design_quality - 0.12 * prior_knowledge, 0.9), 0, 10)

            expertise_reversal_penalty = 0.0
            if expertise_level in ["advanced", "expert"] and condition in ["worked_example", "redundant"]:
                expertise_reversal_penalty = 0.55 if condition == "worked_example" else 0.80

            accuracy_latent = (
                -0.8
                + 0.50 * working_memory_capacity
                + 0.38 * prior_knowledge
                + 0.30 * germane_load
                + 0.22 * design_quality
                - 0.42 * intrinsic_load
                - 0.55 * extraneous_load
                - 0.22 * split_attention
                - 0.18 * redundancy
                - 0.45 * expertise_reversal_penalty
                + rng.normal(0, 0.35)
            )
            p_correct = logistic(np.array([accuracy_latent]))[0]
            correct = int(rng.random() < p_correct)

            performance_accuracy = np.clip(rng.normal(p_correct, 0.08), 0, 1)
            error_rate = 1.0 - performance_accuracy

            transfer_score = np.clip(
                rng.normal(
                    18
                    + 5.0 * germane_load
                    + 3.0 * prior_knowledge
                    + 2.2 * design_quality
                    - 3.2 * extraneous_load
                    - 1.4 * expertise_reversal_penalty,
                    7.0,
                ),
                0,
                100,
            )

            learning_gain = np.clip(
                rng.normal(
                    5
                    + 2.9 * germane_load
                    + 2.0 * design_quality
                    - 1.7 * extraneous_load
                    - 0.8 * intrinsic_load
                    + 0.65 * correct
                    - 1.2 * expertise_reversal_penalty,
                    5.0,
                ),
                0,
                100,
            )

            rt_ms = int(
                np.clip(
                    np.exp(
                        math.log(2100)
                        + 0.048 * intrinsic_load
                        + 0.070 * extraneous_load
                        + 0.030 * temporal_demand
                        - 0.045 * prior_knowledge
                        - 0.030 * design_quality
                        - 0.060 * correct
                        - 0.055 * ce["ai"]
                        + speed_factor
                        + rng.normal(0, 0.12)
                    ),
                    150,
                    60000,
                )
            )

            confidence = np.clip(
                rng.normal(4.4 + 2.8 * performance_accuracy + 0.18 * prior_knowledge - 0.18 * extraneous_load - 0.12 * frustration, 0.9),
                0,
                10,
            )

            mental_efficiency = (performance_accuracy - subjective_effort / 10.0) / np.sqrt(2)

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "task_id": task_id,
                    "expertise_level": expertise_level,
                    "intrinsic_load": round(float(intrinsic_load), 3),
                    "extraneous_load": round(float(extraneous_load), 3),
                    "germane_load": round(float(germane_load), 3),
                    "element_interactivity": round(float(element_interactivity), 3),
                    "prior_knowledge": round(float(prior_knowledge), 3),
                    "working_memory_capacity": round(float(working_memory_capacity), 3),
                    "design_quality": round(float(design_quality), 3),
                    "split_attention": round(float(split_attention), 3),
                    "redundancy": round(float(redundancy), 3),
                    "subjective_effort": round(float(subjective_effort), 3),
                    "mental_demand": round(float(mental_demand), 3),
                    "temporal_demand": round(float(temporal_demand), 3),
                    "frustration": round(float(frustration), 3),
                    "performance_accuracy": round(float(performance_accuracy), 4),
                    "correct": correct,
                    "rt_ms": rt_ms,
                    "error_rate": round(float(error_rate), 4),
                    "transfer_score": round(float(transfer_score), 3),
                    "learning_gain": round(float(learning_gain), 3),
                    "mental_efficiency": round(float(mental_efficiency), 4),
                    "confidence": round(float(confidence), 3),
                }
            )

    df = pd.DataFrame(rows)
    df["total_load"] = df["intrinsic_load"] + df["extraneous_load"] + df["germane_load"]
    df["effective_load"] = df["intrinsic_load"] + df["extraneous_load"] - 0.25 * df["prior_knowledge"]
    df["overload_margin"] = df["working_memory_capacity"] + 0.45 * df["prior_knowledge"] - (df["intrinsic_load"] + df["extraneous_load"] + 0.55 * df["germane_load"])
    return df


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    for col in ["total_load", "effective_load", "overload_margin"]:
        if col not in df.columns:
            df["total_load"] = df["intrinsic_load"] + df["extraneous_load"] + df["germane_load"]
            df["effective_load"] = df["intrinsic_load"] + df["extraneous_load"] - 0.25 * df["prior_knowledge"]
            df["overload_margin"] = df["working_memory_capacity"] + 0.45 * df["prior_knowledge"] - (df["intrinsic_load"] + df["extraneous_load"] + 0.55 * df["germane_load"])

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("correct", "size"),
            participants=("participant", "nunique"),
            mean_intrinsic=("intrinsic_load", "mean"),
            mean_extraneous=("extraneous_load", "mean"),
            mean_germane=("germane_load", "mean"),
            mean_total_load=("total_load", "mean"),
            mean_effort=("subjective_effort", "mean"),
            mean_mental_demand=("mental_demand", "mean"),
            mean_frustration=("frustration", "mean"),
            accuracy=("performance_accuracy", "mean"),
            correct_rate=("correct", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_learning_gain=("learning_gain", "mean"),
            mean_efficiency=("mental_efficiency", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_expertise = (
        df.groupby("expertise_level")
        .agg(
            n_trials=("correct", "size"),
            mean_prior_knowledge=("prior_knowledge", "mean"),
            mean_effective_load=("effective_load", "mean"),
            correct_rate=("correct", "mean"),
            mean_effort=("subjective_effort", "mean"),
            mean_transfer=("transfer_score", "mean"),
            mean_efficiency=("mental_efficiency", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_expertise.to_csv(outputs / "summary_by_expertise.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if "total_load" not in df.columns:
        df["total_load"] = df["intrinsic_load"] + df["extraneous_load"] + df["germane_load"]
    if "effective_load" not in df.columns:
        df["effective_load"] = df["intrinsic_load"] + df["extraneous_load"] - 0.25 * df["prior_knowledge"]

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels/scipy are not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    correct_formula = (
        "correct ~ condition + domain + expertise_level + intrinsic_load + extraneous_load + "
        "germane_load + element_interactivity + prior_knowledge + working_memory_capacity + "
        "design_quality + split_attention + redundancy + subjective_effort"
    )
    correct_model = smf.glm(correct_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Correct-response logistic model ===\n")
    model_text.append(str(correct_model.summary()))

    accuracy_formula = (
        "performance_accuracy ~ condition + domain + expertise_level + intrinsic_load + "
        "extraneous_load + germane_load + prior_knowledge + working_memory_capacity + "
        "design_quality + split_attention + redundancy + mental_demand + frustration"
    )
    accuracy_model = smf.ols(accuracy_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Performance-accuracy model ===\n")
    model_text.append(str(accuracy_model.summary()))

    effort_formula = (
        "subjective_effort ~ condition + domain + expertise_level + intrinsic_load + "
        "extraneous_load + germane_load + element_interactivity + prior_knowledge + "
        "design_quality + split_attention + redundancy"
    )
    effort_model = smf.ols(effort_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Subjective-effort model ===\n")
    model_text.append(str(effort_model.summary()))

    transfer_formula = (
        "transfer_score ~ condition + domain + expertise_level + germane_load + "
        "extraneous_load + intrinsic_load + prior_knowledge + design_quality + "
        "performance_accuracy + subjective_effort"
    )
    transfer_model = smf.ols(transfer_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Transfer-score model ===\n")
    model_text.append(str(transfer_model.summary()))

    efficiency_formula = (
        "mental_efficiency ~ condition + domain + expertise_level + intrinsic_load + "
        "extraneous_load + germane_load + prior_knowledge + design_quality + "
        "split_attention + redundancy"
    )
    efficiency_model = smf.ols(efficiency_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Mental-efficiency model ===\n")
    model_text.append(str(efficiency_model.summary()))

    rt_df = df[df["rt_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["rt_ms"])
    rt_formula = (
        "log_rt ~ condition + domain + expertise_level + intrinsic_load + extraneous_load + "
        "germane_load + prior_knowledge + design_quality + temporal_demand + correct + confidence"
    )
    rt_model = smf.ols(rt_formula, data=rt_df).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    summary = (
        df.groupby("total_load")
        .agg(acc=("correct", "mean"))
        .reset_index()
    )
    try:
        params, _ = curve_fit(load_decline, summary["total_load"].values, summary["acc"].values, p0=[1.0, 0.5, 10.0], maxfev=10000)
        pd.DataFrame([{"a": params[0], "b": params[1], "threshold_c": params[2]}]).to_csv(outputs / "nonlinear_load_decline_parameters.csv", index=False)
    except Exception as exc:
        pd.DataFrame([{"a": np.nan, "b": np.nan, "threshold_c": np.nan, "error": str(exc)}]).to_csv(outputs / "nonlinear_load_decline_parameters.csv", index=False)

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": accuracy_model.params.index,
            "accuracy_coef": accuracy_model.params.values,
            "accuracy_se": accuracy_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "performance_accuracy_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/cognitive_load_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=260)
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
        default_input = Path("data/cognitive_load_trials.csv")
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
