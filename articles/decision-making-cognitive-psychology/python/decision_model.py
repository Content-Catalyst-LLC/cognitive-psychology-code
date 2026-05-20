#!/usr/bin/env python3
"""
Decision-making research model.

This script can:
1. Generate synthetic decision-making trial data.
2. Estimate models for risky choice, expected value, subjective value,
   gain/loss framing, response time, confidence, decision quality,
   AI agreement, and verification burden.
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


CONDITIONS = ["control", "gain_frame", "loss_frame", "time_pressure", "high_load", "low_load", "affect_cue", "ai_assisted", "naturalistic"]
DOMAINS = ["general", "risk", "health", "finance", "legal", "medical", "policy", "technology", "ai", "environment"]
FRAMES = ["gain", "loss", "neutral", "survival", "mortality", "success", "failure"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def probability_weight(p: np.ndarray, gamma: float) -> np.ndarray:
    p = np.clip(p, 1e-6, 1 - 1e-6)
    numerator = p ** gamma
    denominator = (p ** gamma + (1 - p) ** gamma) ** (1 / gamma)
    return numerator / denominator


def utility(payoff: np.ndarray, alpha: float = 0.88, beta: float = 0.88, lamb: float = 2.25) -> np.ndarray:
    payoff = np.asarray(payoff)
    return np.where(payoff >= 0, payoff ** alpha, -lamb * (np.abs(payoff) ** beta))


def generate_dataset(n_participants: int = 300, trials_per_participant: int = 16, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"load": 0.0, "pressure": 0.0, "quality": 0.00, "rt": 0.00, "ai": 0},
        "gain_frame": {"load": 0.2, "pressure": 0.2, "quality": 0.02, "rt": -0.05, "ai": 0},
        "loss_frame": {"load": 0.4, "pressure": 0.3, "quality": -0.04, "rt": -0.03, "ai": 0},
        "time_pressure": {"load": 0.5, "pressure": 2.8, "quality": -0.10, "rt": -0.28, "ai": 0},
        "high_load": {"load": 3.0, "pressure": 0.7, "quality": -0.12, "rt": 0.05, "ai": 0},
        "low_load": {"load": -1.2, "pressure": -0.4, "quality": 0.07, "rt": 0.02, "ai": 0},
        "affect_cue": {"load": 0.6, "pressure": 0.5, "quality": -0.02, "rt": -0.08, "ai": 0},
        "ai_assisted": {"load": -0.6, "pressure": -0.2, "quality": 0.05, "rt": -0.14, "ai": 1},
        "naturalistic": {"load": 0.8, "pressure": 0.8, "quality": -0.02, "rt": 0.10, "ai": 0},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        numeracy = rng.normal(0, 0.55)
        reflection = rng.normal(0, 0.55)
        risk_tolerance = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.14)
        base_lambda = float(np.clip(rng.normal(2.2 - 0.15 * risk_tolerance, 0.35), 0.9, 4.5))
        base_threshold = float(np.clip(rng.normal(1.25 + 0.12 * reflection, 0.20), 0.55, 2.20))

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            ce = condition_effects[condition]
            scenario_id = f"D{trial:03d}_{participant}"

            option_count = int(np.clip(round(rng.normal(3.0 + (domain in ["policy", "medical", "legal", "ai"]) * 1.2, 1.0)), 2, 8))
            frame = rng.choice(FRAMES)
            if condition == "gain_frame":
                frame = rng.choice(["gain", "survival", "success"])
            if condition == "loss_frame":
                frame = rng.choice(["loss", "mortality", "failure"])

            gain_loss = "gain" if frame in ["gain", "survival", "success"] else "loss" if frame in ["loss", "mortality", "failure"] else rng.choice(["mixed", "neutral"])
            probability = float(np.clip(rng.beta(2.0, 2.4), 0.02, 0.98))
            payoff_sign = 1 if gain_loss == "gain" else -1 if gain_loss == "loss" else rng.choice([-1, 1], p=[0.35, 0.65])
            payoff = float(payoff_sign * np.clip(rng.lognormal(np.log(240), 0.65), 20, 1000))
            reference_point = float(rng.normal(0, 30))
            expected_value = float(probability * payoff)

            lamb = float(np.clip(base_lambda + 0.25 * (gain_loss == "loss") + 0.10 * (condition == "loss_frame"), 0.8, 4.8))
            gamma = float(np.clip(rng.normal(0.72 - 0.06 * (condition in ["affect_cue", "loss_frame"]), 0.08), 0.35, 1.0))
            p_weight = float(probability_weight(np.array([probability]), gamma)[0])
            adjusted_payoff = payoff - reference_point
            expected_utility = float(probability * utility(np.array([adjusted_payoff]), lamb=lamb)[0])
            subjective_value = float(p_weight * utility(np.array([adjusted_payoff]), lamb=lamb)[0])

            affective_valence = float(np.clip(rng.normal(0.6 + 2.5 * (condition == "affect_cue") + 1.2 * (gain_loss == "gain") - 1.4 * (gain_loss == "loss"), 1.3), -5, 5))
            cognitive_load = float(np.clip(rng.normal(4.3 + ce["load"] + 0.30 * option_count + 0.25 * abs(affective_valence) - 0.15 * reflection, 1.0), 0, 10))
            time_pressure = float(np.clip(rng.normal(4.6 + ce["pressure"], 1.1), 0, 10))
            uncertainty = float(np.clip(rng.normal(4.8 + 1.0 * (domain in ["policy", "legal", "medical", "environment"]) + 0.55 * (gain_loss == "mixed"), 1.2), 0, 10))

            evidence_strength = float(np.clip(rng.normal(0.006 * subjective_value + 0.25 * reflection - 0.12 * uncertainty + 0.18 * ce["quality"], 1.1), -5, 5))
            drift_rate_proxy = float(np.clip(0.22 * evidence_strength + 0.10 * numeracy + 0.06 * affective_valence - 0.08 * cognitive_load - 0.05 * uncertainty, -3, 3))
            decision_threshold = float(np.clip(base_threshold + 0.08 * uncertainty - 0.08 * time_pressure + 0.12 * (domain in ["legal", "medical", "finance"]) + 0.06 * option_count, 0.45, 3.0))

            ai_recommendation = int(ce["ai"])
            ai_quality = float(np.clip(rng.normal(0.68 + 0.10 * (domain != "ai") - 0.05 * uncertainty, 0.12), 0.20, 0.95))
            verification_burden = float(np.clip((0 if not ai_recommendation else rng.normal(3.0 + 0.65 * uncertainty + 0.25 * option_count - 0.8 * ai_quality, 1.1)), 0, 10))
            ai_agreement_prob = logistic(np.array([-0.2 + 1.4 * ai_quality - 0.20 * verification_burden + 0.30 * (subjective_value > 0)]))[0] if ai_recommendation else 0.0
            ai_agreement = int(ai_recommendation and rng.random() < ai_agreement_prob)

            risky_latent = (
                -0.35
                + 0.010 * subjective_value
                + 1.25 * p_weight
                + 0.38 * risk_tolerance
                + 0.28 * (frame in ["loss", "mortality", "failure"])
                - 0.24 * lamb * (gain_loss == "loss")
                + 0.12 * affective_valence
                - 0.07 * cognitive_load
                - 0.05 * uncertainty
                + 0.28 * ai_recommendation * ai_agreement
                + rng.normal(0, 0.30)
            )
            choice_risky = int(rng.random() < logistic(np.array([risky_latent]))[0])
            optimal_by_ev = int(expected_value > 0)
            optimal_choice = int(choice_risky == optimal_by_ev)

            accuracy = float(np.clip(0.35 + 0.38 * optimal_choice + 0.05 * reflection + 0.04 * numeracy - 0.03 * cognitive_load - 0.03 * uncertainty + ce["quality"] + 0.04 * ai_recommendation * ai_agreement + rng.normal(0, 0.07), 0, 1))
            confidence = float(np.clip(0.46 + 0.35 * accuracy + 0.04 * abs(drift_rate_proxy) - 0.025 * uncertainty + 0.05 * ai_recommendation * ai_agreement + rng.normal(0, 0.09), 0, 1))

            rt_ms = int(np.clip(np.exp(math.log(2200) + ce["rt"] + 0.20 * decision_threshold - 0.08 * abs(drift_rate_proxy) + 0.035 * cognitive_load + 0.030 * uncertainty - 0.050 * time_pressure + speed_factor + rng.normal(0, 0.14)), 150, 60000))
            feedback_valence = float(np.clip(rng.normal(2.0 * optimal_choice - 1.2 * (1 - optimal_choice) + 0.005 * expected_value, 1.0), -5, 5))
            regret = float(np.clip(rng.normal(5.8 * (1 - optimal_choice) + 1.5 * (gain_loss == "loss") + 0.25 * uncertainty - 1.8 * optimal_choice, 1.2), 0, 10))
            decision_quality = float(np.clip(0.30 + 0.45 * optimal_choice + 0.18 * accuracy + 0.08 * confidence - 0.04 * cognitive_load - 0.03 * uncertainty - 0.035 * verification_burden + ce["quality"] + rng.normal(0, 0.07), 0, 1))

            if ai_recommendation:
                choice_option = "AI_B" if ai_agreement else "Human_A"
            else:
                choice_option = "Risky" if choice_risky else "Certain"

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "scenario_id": scenario_id,
                    "option_count": option_count,
                    "frame": frame,
                    "gain_loss": gain_loss,
                    "probability": round(probability, 4),
                    "payoff": round(payoff, 3),
                    "reference_point": round(reference_point, 3),
                    "expected_value": round(expected_value, 3),
                    "expected_utility": round(expected_utility, 3),
                    "loss_aversion_lambda": round(lamb, 4),
                    "probability_weight": round(p_weight, 4),
                    "subjective_value": round(subjective_value, 3),
                    "evidence_strength": round(evidence_strength, 3),
                    "drift_rate_proxy": round(drift_rate_proxy, 4),
                    "decision_threshold": round(decision_threshold, 4),
                    "choice_risky": choice_risky,
                    "choice_option": choice_option,
                    "optimal_choice": optimal_choice,
                    "accuracy": round(accuracy, 4),
                    "confidence": round(confidence, 4),
                    "affective_valence": round(affective_valence, 3),
                    "cognitive_load": round(cognitive_load, 3),
                    "time_pressure": round(time_pressure, 3),
                    "uncertainty": round(uncertainty, 3),
                    "response_time_ms": rt_ms,
                    "feedback_valence": round(feedback_valence, 3),
                    "regret": round(regret, 3),
                    "decision_quality": round(decision_quality, 4),
                    "ai_recommendation": ai_recommendation,
                    "ai_agreement": ai_agreement,
                    "verification_burden": round(verification_burden, 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("choice_risky", "size"),
            participants=("participant", "nunique"),
            risky_choice_rate=("choice_risky", "mean"),
            optimal_choice_rate=("optimal_choice", "mean"),
            mean_accuracy=("accuracy", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_decision_quality=("decision_quality", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_cognitive_load=("cognitive_load", "mean"),
            mean_time_pressure=("time_pressure", "mean"),
            mean_uncertainty=("uncertainty", "mean"),
            mean_regret=("regret", "mean"),
            ai_agreement_rate=("ai_agreement", "mean"),
            mean_verification_burden=("verification_burden", "mean"),
        )
        .reset_index()
    )

    by_frame = (
        df.groupby(["frame", "gain_loss"])
        .agg(
            n_trials=("choice_risky", "size"),
            risky_choice_rate=("choice_risky", "mean"),
            optimal_choice_rate=("optimal_choice", "mean"),
            mean_subjective_value=("subjective_value", "mean"),
            mean_decision_quality=("decision_quality", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_frame.to_csv(outputs / "summary_by_frame_gain_loss.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    risky_model = smf.glm(
        "choice_risky ~ condition + frame * gain_loss + probability + payoff + expected_value + "
        "subjective_value + probability_weight + loss_aversion_lambda + cognitive_load + "
        "time_pressure + uncertainty + affective_valence + ai_recommendation + ai_agreement",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Risky-choice logistic model ===\n")
    model_text.append(str(risky_model.summary()))

    optimal_model = smf.glm(
        "optimal_choice ~ condition + domain + option_count + expected_value + subjective_value + "
        "evidence_strength + drift_rate_proxy + decision_threshold + cognitive_load + "
        "time_pressure + uncertainty + confidence + ai_recommendation + verification_burden",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Optimal-choice logistic model ===\n")
    model_text.append(str(optimal_model.summary()))

    quality_model = smf.ols(
        "decision_quality ~ condition + domain + optimal_choice + accuracy + confidence + "
        "cognitive_load + time_pressure + uncertainty + regret + ai_recommendation + "
        "ai_agreement + verification_burden",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Decision-quality model ===\n")
    model_text.append(str(quality_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["response_time_ms"])
    rt_model = smf.ols(
        "log_rt ~ condition + frame + gain_loss + option_count + evidence_strength + "
        "drift_rate_proxy + decision_threshold + cognitive_load + time_pressure + "
        "uncertainty + optimal_choice + confidence + ai_recommendation + verification_burden",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    confidence_model = smf.ols(
        "confidence ~ condition + domain + accuracy + optimal_choice + drift_rate_proxy + "
        "decision_threshold + uncertainty + cognitive_load + ai_recommendation + ai_agreement",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Confidence model ===\n")
    model_text.append(str(confidence_model.summary()))

    ai_df = df[df["ai_recommendation"] == 1].copy()
    if len(ai_df) > 25:
        ai_model = smf.glm(
            "ai_agreement ~ domain + probability + payoff + subjective_value + evidence_strength + "
            "confidence + uncertainty + cognitive_load + verification_burden",
            data=ai_df,
            family=sm.families.Binomial(),
        ).fit(cov_type="cluster", cov_kwds={"groups": ai_df["participant"]})
        model_text.append("\n\n=== AI-agreement model ===\n")
        model_text.append(str(ai_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

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

    pd.DataFrame(
        {
            "term": rt_model.params.index,
            "response_time_coef": rt_model.params.values,
            "response_time_se": rt_model.bse.values,
        }
    ).to_csv(outputs / "response_time_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/decision_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=300)
    parser.add_argument("--trials", type=int, default=16)
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
        default_input = Path("data/decision_trials.csv")
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
