#!/usr/bin/env python3
"""
Cognitive psychology and behavioral economics.

This script can:
1. Generate synthetic behavioral-economics trial data.
2. Estimate models for risky choice, default acceptance, willingness to pay,
   decision time, and prospect-theory value.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
behavioral economics, policy research, and decision-science analysis.
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


CONDITIONS = ["control", "gain_frame", "loss_frame", "default_nudge", "social_norm", "high_load"]
DOMAINS = ["savings", "health", "environment", "consumer", "risk", "time"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def prospect_value(x: np.ndarray, alpha: float = 0.88, beta: float = 0.88, lam: float = 2.25) -> np.ndarray:
    """Prospect-theory style value function."""
    x = np.asarray(x)
    gains = np.power(np.maximum(x, 0), alpha)
    losses = -lam * np.power(np.maximum(-x, 0), beta)
    return np.where(x >= 0, gains, losses)


def discounted_value(amount: np.ndarray, delay_days: np.ndarray, k: float = 0.015) -> np.ndarray:
    """Simple hyperbolic discounting function."""
    return amount / (1.0 + k * delay_days)


def generate_dataset(
    n_participants: int = 220,
    trials_per_participant: int = 12,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"load": 3.6, "attention": 7.3, "default": 0, "norm": 2.5},
        "gain_frame": {"load": 3.8, "attention": 7.2, "default": 0, "norm": 3.0},
        "loss_frame": {"load": 5.6, "attention": 6.3, "default": 0, "norm": 3.2},
        "default_nudge": {"load": 4.1, "attention": 7.0, "default": 1, "norm": 4.2},
        "social_norm": {"load": 4.4, "attention": 6.8, "default": 0, "norm": 7.8},
        "high_load": {"load": 8.0, "attention": 5.0, "default": 1, "norm": 5.8},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        risk_tolerance = rng.normal(0, 0.55)
        default_susceptibility = rng.normal(0, 0.45)
        participant_speed = rng.normal(0, 0.16)
        lam = np.clip(rng.normal(2.25, 0.35), 1.05, 4.0)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            params = condition_effects[condition]

            if condition == "gain_frame":
                frame = "gain"
            elif condition == "loss_frame":
                frame = "loss"
            else:
                frame = rng.choice(["gain", "loss", "neutral"], p=[0.36, 0.32, 0.32])

            reference_point = float(rng.choice([0, 50, 100, 250]))
            sign = -1 if frame == "loss" else 1
            amount = sign * float(np.clip(rng.normal(90, 45), 10, 250))
            probability = float(np.clip(rng.beta(3.0, 2.2), 0.05, 0.98))
            delay_days = float(rng.choice([0, 7, 14, 30, 60, 90, 180, 365]))

            cognitive_load = np.clip(rng.normal(params["load"], 0.9), 0, 10)
            attention_score = np.clip(rng.normal(params["attention"] - 0.12 * cognitive_load, 0.9), 0, 10)
            default_present = int(params["default"])
            social_norm_strength = np.clip(rng.normal(params["norm"], 1.0), 0, 10)

            subjective_value = prospect_value(np.array([amount]), lam=lam)[0]
            time_value = discounted_value(np.array([abs(amount)]), np.array([delay_days]))[0]

            risky_logit = (
                -0.60
                + 0.018 * subjective_value
                + 0.85 * probability
                + 0.32 * risk_tolerance
                + 0.12 * social_norm_strength
                - 0.14 * cognitive_load
                + (0.55 if frame == "loss" else 0.0)
                - 0.003 * delay_days
                + rng.normal(0, 0.25)
            )
            risky_choice = int(rng.random() < logistic(np.array([risky_logit]))[0])

            default_logit = (
                -1.4
                + 2.2 * default_present
                + 0.25 * cognitive_load
                + 0.20 * social_norm_strength
                - 0.18 * attention_score
                + 0.38 * default_susceptibility
                + rng.normal(0, 0.25)
            )
            default_accepted = int(rng.random() < logistic(np.array([default_logit]))[0])

            willingness_to_pay = np.clip(
                0.42 * abs(amount)
                + 4.5 * social_norm_strength
                - 2.2 * cognitive_load
                + 6.5 * risky_choice
                + 4.0 * default_accepted
                + rng.normal(0, 10.0),
                0,
                500,
            )

            log_dt = (
                math.log(2200)
                + 0.055 * cognitive_load
                - 0.035 * attention_score
                + 0.0025 * delay_days
                + 0.020 * abs(amount) / 50.0
                + participant_speed
                + rng.normal(0, 0.12)
            )
            decision_time_ms = int(np.clip(np.exp(log_dt), 150, 60000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "trial": trial,
                    "choice_domain": domain,
                    "gain_loss_frame": frame,
                    "reference_point": reference_point,
                    "outcome_amount": round(float(amount), 3),
                    "probability": round(float(probability), 3),
                    "delay_days": delay_days,
                    "cognitive_load": round(float(cognitive_load), 3),
                    "attention_score": round(float(attention_score), 3),
                    "default_present": default_present,
                    "social_norm_strength": round(float(social_norm_strength), 3),
                    "loss_aversion_lambda": round(float(lam), 3),
                    "subjective_value": round(float(subjective_value), 3),
                    "discounted_value": round(float(time_value), 3),
                    "risky_choice": risky_choice,
                    "default_accepted": default_accepted,
                    "willingness_to_pay": round(float(willingness_to_pay), 3),
                    "decision_time_ms": decision_time_ms,
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("risky_choice", "size"),
            participants=("participant", "nunique"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_attention=("attention_score", "mean"),
            risky_choice_rate=("risky_choice", "mean"),
            default_acceptance_rate=("default_accepted", "mean"),
            mean_wtp=("willingness_to_pay", "mean"),
            mean_decision_time_ms=("decision_time_ms", "mean"),
            mean_social_norm=("social_norm_strength", "mean"),
            mean_lambda=("loss_aversion_lambda", "mean"),
        )
        .reset_index()
    )

    by_domain = (
        df.groupby("choice_domain")
        .agg(
            n_trials=("risky_choice", "size"),
            risky_choice_rate=("risky_choice", "mean"),
            default_acceptance_rate=("default_accepted", "mean"),
            mean_wtp=("willingness_to_pay", "mean"),
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

    risky_formula = (
        "risky_choice ~ condition + gain_loss_frame + probability + outcome_amount + "
        "cognitive_load + attention_score + social_norm_strength + loss_aversion_lambda + delay_days"
    )

    risky_model = smf.glm(
        risky_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Risky-choice model: logistic GLM ===\n")
    model_text.append(str(risky_model.summary()))

    default_formula = (
        "default_accepted ~ condition + default_present + cognitive_load + "
        "attention_score + social_norm_strength + gain_loss_frame"
    )

    default_model = smf.glm(
        default_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Default-acceptance model: logistic GLM ===\n")
    model_text.append(str(default_model.summary()))

    wtp_formula = (
        "willingness_to_pay ~ condition + gain_loss_frame + outcome_amount + probability + "
        "delay_days + cognitive_load + attention_score + social_norm_strength + risky_choice"
    )

    wtp_model = smf.ols(wtp_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Willingness-to-pay model: cluster-robust OLS ===\n")
    model_text.append(str(wtp_model.summary()))

    rt_df = df[df["decision_time_ms"] >= 150].copy()
    rt_df["log_decision_time"] = np.log(rt_df["decision_time_ms"])

    rt_formula = (
        "log_decision_time ~ condition + gain_loss_frame + cognitive_load + "
        "attention_score + delay_days + probability + outcome_amount"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Decision-time model: log decision time ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": risky_model.params.index,
            "risky_choice_coef": risky_model.params.values,
            "risky_choice_se": risky_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "risky_choice_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/behavioral_economics_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=220)
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
        default_input = Path("data/behavioral_economics_trials.csv")
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
