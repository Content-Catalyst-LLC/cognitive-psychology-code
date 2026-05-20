#!/usr/bin/env python3
"""
Cognitive-bias research model.

This script can:
1. Generate synthetic cognitive-bias trial data.
2. Estimate models for framing, anchoring, confirmation bias, overconfidence,
   calibration error, prospect-theory variables, risky choice, decision quality,
   response time, and debiasing effects.
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


CONDITIONS = ["control", "framing", "anchoring", "confirmation", "overconfidence", "base_rate", "prospect", "debiasing", "ai_assisted"]
DOMAINS = ["general", "risk", "health", "finance", "legal", "medical", "policy", "technology", "ai"]
BIAS_MAP = {
    "control": "none",
    "framing": "framing",
    "anchoring": "anchoring",
    "confirmation": "confirmation",
    "overconfidence": "overconfidence",
    "base_rate": "base_rate_neglect",
    "prospect": "loss_aversion",
    "debiasing": "mixed",
    "ai_assisted": "automation",
}
DEBIASING = ["none", "checklist", "base_rate_prompt", "consider_opposite", "feedback", "premortem", "statistical_training", "independent_review"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def probability_weight(p: np.ndarray, gamma: float) -> np.ndarray:
    p = np.clip(p, 1e-6, 1 - 1e-6)
    numerator = p ** gamma
    denominator = (p ** gamma + (1 - p) ** gamma) ** (1 / gamma)
    return numerator / denominator


def subjective_value(payoff: np.ndarray, alpha: float, beta: float, lamb: float) -> np.ndarray:
    payoff = np.asarray(payoff)
    return np.where(payoff >= 0, payoff ** alpha, -lamb * (np.abs(payoff) ** beta))


def generate_dataset(n_participants: int = 300, trials_per_participant: int = 14, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"quality": 0.00, "calibration": 0.00, "rt": 0.00, "load": 0.00},
        "framing": {"quality": -0.08, "calibration": 0.06, "rt": -0.08, "load": 0.25},
        "anchoring": {"quality": -0.10, "calibration": 0.10, "rt": -0.10, "load": 0.30},
        "confirmation": {"quality": -0.14, "calibration": 0.12, "rt": 0.06, "load": 0.45},
        "overconfidence": {"quality": -0.08, "calibration": 0.18, "rt": -0.05, "load": 0.20},
        "base_rate": {"quality": -0.12, "calibration": 0.12, "rt": -0.03, "load": 0.35},
        "prospect": {"quality": -0.07, "calibration": 0.08, "rt": 0.00, "load": 0.35},
        "debiasing": {"quality": 0.12, "calibration": -0.08, "rt": 0.12, "load": -0.10},
        "ai_assisted": {"quality": 0.02, "calibration": 0.05, "rt": -0.12, "load": -0.20},
    }

    debiasing_effects = {
        "none": 0.00,
        "checklist": 0.08,
        "base_rate_prompt": 0.10,
        "consider_opposite": 0.12,
        "feedback": 0.12,
        "premortem": 0.09,
        "statistical_training": 0.14,
        "independent_review": 0.11,
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        numeracy = rng.normal(0, 0.55)
        analytic_reflection = rng.normal(0, 0.55)
        susceptibility = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.14)
        base_lambda = float(np.clip(rng.normal(2.15 + 0.25 * susceptibility, 0.35), 1.0, 4.0))

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            scenario_id = f"CB{trial:03d}_{participant}"
            bias_type = BIAS_MAP[condition]

            if condition == "debiasing":
                debiasing_condition = rng.choice(DEBIASING[1:])
            elif condition in ["control"]:
                debiasing_condition = "none"
            else:
                debiasing_condition = rng.choice(["none", "none", "none", "checklist", "base_rate_prompt", "consider_opposite"])

            intervention = debiasing_effects[debiasing_condition]
            ce = condition_effects[condition]

            frame = rng.choice(["gain", "loss", "neutral", "survival", "mortality", "success", "failure"])
            gain_loss = "gain" if frame in ["gain", "survival", "success"] else "loss" if frame in ["loss", "mortality", "failure"] else rng.choice(["mixed", "neutral"])

            probability = float(np.clip(rng.beta(2.0, 2.5), 0.02, 0.98))
            base_rate = float(np.clip(probability + rng.normal(0, 0.10), 0.02, 0.98))
            payoff_sign = -1 if gain_loss == "loss" else 1 if gain_loss == "gain" else rng.choice([-1, 1])
            payoff = float(payoff_sign * np.clip(rng.lognormal(np.log(180), 0.65), 20, 1000))
            gamma = float(np.clip(rng.normal(0.72 - 0.08 * susceptibility, 0.08), 0.35, 1.0))
            p_weight = float(probability_weight(np.array([probability]), gamma)[0])
            lambda_i = float(np.clip(base_lambda + 0.18 * (condition == "prospect") - 0.08 * intervention, 0.8, 4.5))
            sv = float(subjective_value(np.array([payoff]), 0.88, 0.88, lambda_i)[0])

            anchor_value = float(np.clip(50 + (25 if rng.random() < 0.5 else -25) + rng.normal(0, 8), 0, 100))
            representativeness = float(np.clip(rng.normal(5.5 + 2.4 * (condition == "base_rate") + 0.5 * susceptibility, 1.1), 0, 10))
            evidence_valence = float(np.clip(rng.normal(0.5 + 2.2 * (frame in ["gain", "survival", "success"]) - 2.2 * (frame in ["loss", "mortality", "failure"]), 1.3), -5, 5))
            prior_belief = float(np.clip(rng.beta(2.4, 2.4), 0.01, 0.99))
            confirmation_congruence = float(np.clip(0.52 + 0.22 * (condition == "confirmation") + 0.10 * susceptibility - 0.16 * intervention + rng.normal(0, 0.10), 0, 1))

            cognitive_load = float(np.clip(rng.normal(4.5 + ce["load"] + 0.25 * abs(evidence_valence) + 0.35 * susceptibility - 0.25 * intervention, 1.0), 0, 10))
            time_pressure = float(np.clip(rng.normal(5.0 + 0.5 * (condition != "debiasing") - 0.25 * intervention, 1.2), 0, 10))

            true_accuracy_latent = (
                -0.2
                + 1.5 * probability
                + 0.22 * numeracy
                + 0.18 * analytic_reflection
                - 0.12 * cognitive_load
                - 0.08 * time_pressure
                + 0.35 * intervention
                + rng.normal(0, 0.25)
            )
            actual_accuracy = float(np.clip(logistic(np.array([true_accuracy_latent]))[0] + rng.normal(0, 0.06), 0, 1))

            confidence_bias = (
                0.08 * (condition == "overconfidence")
                + 0.06 * (condition == "confirmation")
                + 0.04 * (condition == "anchoring")
                + ce["calibration"]
                + 0.06 * susceptibility
                - 0.10 * intervention
            )
            confidence_rating = float(np.clip(actual_accuracy + confidence_bias + rng.normal(0, 0.08), 0, 1))
            calibration_error = float(abs(confidence_rating - actual_accuracy))
            overconfidence = float(confidence_rating - actual_accuracy)

            risky_latent = (
                -0.40
                + 1.7 * p_weight
                + 0.004 * sv
                + 0.35 * (frame in ["gain", "survival", "success"])
                - 0.55 * (gain_loss == "loss") * lambda_i
                + 0.25 * (condition == "framing") * (1 if frame in ["loss", "mortality", "failure"] else -0.5)
                + 0.10 * analytic_reflection
                - 0.08 * intervention
                + rng.normal(0, 0.25)
            )
            chose_risky = int(rng.random() < logistic(np.array([risky_latent]))[0])
            choice_binary = chose_risky

            criterion = int((probability * max(payoff, 0) + (1 - probability) * min(payoff, 0)) > 0)
            correct_prob = float(np.clip(actual_accuracy + 0.15 * (choice_binary == criterion) - 0.06 * (condition in ["confirmation", "anchoring", "base_rate"]) + 0.06 * intervention, 0.02, 0.98))
            correct = int(rng.random() < correct_prob)

            decision_quality = float(np.clip(0.35 + 0.42 * correct + 0.12 * actual_accuracy - 0.22 * calibration_error - 0.06 * cognitive_load + 0.10 * intervention + rng.normal(0, 0.08), 0, 1))

            review_risk = (
                -1.2
                + 1.8 * calibration_error
                + 0.25 * cognitive_load
                + 0.20 * time_pressure
                + 0.6 * (domain in ["legal", "medical", "finance", "policy"])
                - 1.0 * decision_quality
                + 0.4 * (condition == "ai_assisted")
            )
            institutional_review_flag = int(rng.random() < logistic(np.array([review_risk]))[0])

            response_time_ms = int(np.clip(np.exp(math.log(2100) + ce["rt"] + 0.045 * cognitive_load + 0.025 * time_pressure + 0.20 * intervention - 0.08 * correct + speed_factor + rng.normal(0, 0.14)), 150, 60000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "scenario_id": scenario_id,
                    "bias_type": bias_type,
                    "frame": frame,
                    "gain_loss": gain_loss,
                    "anchor_value": round(anchor_value, 3),
                    "base_rate": round(base_rate, 4),
                    "representativeness": round(representativeness, 3),
                    "evidence_valence": round(evidence_valence, 3),
                    "confirmation_congruence": round(confirmation_congruence, 4),
                    "prior_belief": round(prior_belief, 4),
                    "confidence_rating": round(confidence_rating, 4),
                    "actual_accuracy": round(actual_accuracy, 4),
                    "calibration_error": round(calibration_error, 4),
                    "overconfidence": round(overconfidence, 4),
                    "probability": round(probability, 4),
                    "payoff": round(payoff, 3),
                    "loss_aversion_lambda": round(lambda_i, 4),
                    "probability_weight": round(p_weight, 4),
                    "subjective_value": round(sv, 3),
                    "chose_risky": chose_risky,
                    "choice_binary": choice_binary,
                    "correct": correct,
                    "response_time_ms": response_time_ms,
                    "cognitive_load": round(cognitive_load, 3),
                    "time_pressure": round(time_pressure, 3),
                    "debiasing_condition": debiasing_condition,
                    "decision_quality": round(decision_quality, 4),
                    "institutional_review_flag": institutional_review_flag,
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
            mean_confidence=("confidence_rating", "mean"),
            mean_accuracy=("actual_accuracy", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_overconfidence=("overconfidence", "mean"),
            risky_choice_rate=("chose_risky", "mean"),
            correct_rate=("correct", "mean"),
            mean_decision_quality=("decision_quality", "mean"),
            review_flag_rate=("institutional_review_flag", "mean"),
            mean_rt_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_bias = (
        df.groupby("bias_type")
        .agg(
            n_trials=("correct", "size"),
            correct_rate=("correct", "mean"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_overconfidence=("overconfidence", "mean"),
            risky_choice_rate=("chose_risky", "mean"),
            mean_decision_quality=("decision_quality", "mean"),
            review_flag_rate=("institutional_review_flag", "mean"),
        )
        .reset_index()
    )

    by_debiasing = (
        df.groupby("debiasing_condition")
        .agg(
            n_trials=("correct", "size"),
            mean_calibration_error=("calibration_error", "mean"),
            mean_overconfidence=("overconfidence", "mean"),
            correct_rate=("correct", "mean"),
            mean_decision_quality=("decision_quality", "mean"),
            review_flag_rate=("institutional_review_flag", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_bias.to_csv(outputs / "summary_by_bias_type.csv", index=False)
    by_debiasing.to_csv(outputs / "summary_by_debiasing_condition.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    calibration_model = smf.ols(
        "calibration_error ~ condition + domain + bias_type + frame + gain_loss + confidence_rating + actual_accuracy + cognitive_load + time_pressure + debiasing_condition",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Calibration-error model ===\n")
    model_text.append(str(calibration_model.summary()))

    overconfidence_model = smf.ols(
        "overconfidence ~ condition + domain + bias_type + confidence_rating + actual_accuracy + confirmation_congruence + cognitive_load + time_pressure + debiasing_condition",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Overconfidence model ===\n")
    model_text.append(str(overconfidence_model.summary()))

    risky_model = smf.glm(
        "chose_risky ~ condition + frame * gain_loss + probability + payoff + probability_weight + subjective_value + loss_aversion_lambda + cognitive_load + time_pressure + debiasing_condition",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Risky-choice logistic model ===\n")
    model_text.append(str(risky_model.summary()))

    correct_model = smf.glm(
        "correct ~ condition + domain + bias_type + base_rate + representativeness + confirmation_congruence + confidence_rating + calibration_error + cognitive_load + time_pressure + debiasing_condition",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Correct-decision logistic model ===\n")
    model_text.append(str(correct_model.summary()))

    quality_model = smf.ols(
        "decision_quality ~ condition + domain + bias_type + correct + calibration_error + overconfidence + cognitive_load + time_pressure + debiasing_condition + institutional_review_flag",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Decision-quality model ===\n")
    model_text.append(str(quality_model.summary()))

    review_model = smf.glm(
        "institutional_review_flag ~ condition + domain + bias_type + calibration_error + overconfidence + cognitive_load + time_pressure + decision_quality + debiasing_condition",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Institutional-review flag model ===\n")
    model_text.append(str(review_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["response_time_ms"])
    rt_model = smf.ols(
        "log_rt ~ condition + domain + bias_type + calibration_error + cognitive_load + time_pressure + correct + debiasing_condition",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    pd.DataFrame(
        {
            "term": calibration_model.params.index,
            "calibration_coef": calibration_model.params.values,
            "calibration_se": calibration_model.bse.values,
        }
    ).to_csv(outputs / "calibration_model_coefficients.csv", index=False)

    pd.DataFrame(
        {
            "term": risky_model.params.index,
            "risky_choice_coef": risky_model.params.values,
            "risky_choice_se": risky_model.bse.values,
        }
    ).to_csv(outputs / "risky_choice_model_coefficients.csv", index=False)

    pd.DataFrame(
        {
            "term": quality_model.params.index,
            "decision_quality_coef": quality_model.params.values,
            "decision_quality_se": quality_model.bse.values,
        }
    ).to_csv(outputs / "decision_quality_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/cognitive_bias_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=300)
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
        default_input = Path("data/cognitive_bias_trials.csv")
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
