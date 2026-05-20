#!/usr/bin/env python3
"""
Risk perception and uncertainty research model.

This script can:
1. Generate synthetic risk-perception trial data.
2. Estimate models for perceived risk, subjective probability distortion,
   safe choice, protective action, response time, communication clarity, and confidence.
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
    "gain_frame",
    "loss_frame",
    "high_affect",
    "low_affect",
    "numeric_only",
    "narrative",
    "uncertainty_explicit",
    "ai_advisory",
]

DOMAINS = ["health", "climate", "finance", "technology", "infrastructure", "environment", "public_safety", "ai"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def probability_weight(p: np.ndarray, gamma: float = 0.72) -> np.ndarray:
    """Prelec-like one-parameter probability weighting for simulation."""
    p = np.clip(p, 1e-6, 1 - 1e-6)
    return np.exp(-((-np.log(p)) ** gamma))


def generate_dataset(n_participants: int = 260, trials_per_participant: int = 14, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"affect": 0.0, "loss": 0.0, "clarity": 0.0, "ambiguity": 0.0, "trust": 0.0, "ai": 0.0},
        "gain_frame": {"affect": -0.2, "loss": -0.4, "clarity": 0.4, "ambiguity": -0.2, "trust": 0.2, "ai": 0.0},
        "loss_frame": {"affect": 0.7, "loss": 1.0, "clarity": 0.0, "ambiguity": 0.2, "trust": -0.1, "ai": 0.0},
        "high_affect": {"affect": 1.3, "loss": 0.4, "clarity": -0.2, "ambiguity": 0.3, "trust": -0.2, "ai": 0.0},
        "low_affect": {"affect": -1.0, "loss": -0.2, "clarity": 0.2, "ambiguity": -0.2, "trust": 0.1, "ai": 0.0},
        "numeric_only": {"affect": -0.3, "loss": -0.1, "clarity": 0.5, "ambiguity": -0.5, "trust": 0.1, "ai": 0.0},
        "narrative": {"affect": 0.8, "loss": 0.4, "clarity": 0.3, "ambiguity": 0.1, "trust": 0.0, "ai": 0.0},
        "uncertainty_explicit": {"affect": 0.1, "loss": 0.0, "clarity": 0.8, "ambiguity": 0.8, "trust": 0.5, "ai": 0.0},
        "ai_advisory": {"affect": 0.2, "loss": 0.0, "clarity": 0.5, "ambiguity": 0.2, "trust": 0.0, "ai": 1.0},
    }

    domain_effects = {
        "health": {"severity": 6.6, "familiarity": 6.0, "benefit": 4.6},
        "climate": {"severity": 8.4, "familiarity": 4.0, "benefit": 3.8},
        "finance": {"severity": 6.8, "familiarity": 6.6, "benefit": 4.2},
        "technology": {"severity": 5.2, "familiarity": 6.8, "benefit": 6.8},
        "infrastructure": {"severity": 7.2, "familiarity": 4.8, "benefit": 4.8},
        "environment": {"severity": 7.8, "familiarity": 4.6, "benefit": 4.2},
        "public_safety": {"severity": 7.0, "familiarity": 5.4, "benefit": 3.8},
        "ai": {"severity": 5.8, "familiarity": 5.8, "benefit": 6.2},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        risk_sensitivity = rng.normal(0, 0.55)
        trust_disposition = rng.normal(0, 0.55)
        numeracy = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            ce = condition_effects[condition]
            de = domain_effects[domain]
            scenario_id = f"RP{trial:03d}_{participant}"

            objective_probability = float(np.clip(rng.beta(1.6, 6.8), 0.005, 0.80))
            weighted_probability = probability_weight(np.array([objective_probability]), gamma=0.72 - 0.05 * risk_sensitivity)[0]
            subjective_probability = float(
                np.clip(
                    rng.normal(
                        0.55 * weighted_probability
                        + 0.45 * objective_probability
                        + 0.025 * ce["affect"]
                        + 0.018 * ce["loss"]
                        - 0.020 * numeracy,
                        0.055,
                    ),
                    0,
                    1,
                )
            )

            consequence_rating = float(np.clip(rng.normal(de["severity"] + 0.45 * ce["loss"], 1.0), 0, 10))
            affect_rating = float(np.clip(rng.normal(4.7 + 0.48 * consequence_rating + 1.0 * ce["affect"] + 0.35 * risk_sensitivity, 1.0), 0, 10))
            dread_rating = float(np.clip(rng.normal(3.8 + 0.45 * consequence_rating + 0.55 * affect_rating / 2 + 0.3 * ce["loss"], 1.0), 0, 10))
            familiarity_rating = float(np.clip(rng.normal(de["familiarity"] - 0.20 * ce["ambiguity"], 1.0), 0, 10))
            controllability_rating = float(np.clip(rng.normal(5.6 + 0.20 * familiarity_rating - 0.30 * dread_rating + 0.15 * ce["clarity"], 1.0), 0, 10))
            trust_rating = float(np.clip(rng.normal(5.4 + 0.75 * trust_disposition + 0.55 * ce["trust"] - 0.20 * ce["ai"], 1.0), 0, 10))
            ambiguity_rating = float(np.clip(rng.normal(4.6 + 0.75 * ce["ambiguity"] - 0.20 * ce["clarity"] - 0.12 * numeracy, 1.0), 0, 10))
            communication_clarity = float(np.clip(rng.normal(5.2 + 0.95 * ce["clarity"] + 0.22 * trust_rating - 0.22 * ambiguity_rating, 1.0), 0, 10))
            perceived_benefit = float(np.clip(rng.normal(de["benefit"] - 0.20 * affect_rating + 0.20 * familiarity_rating + 0.25 * ce["ai"], 1.0), 0, 10))

            perceived_risk = float(
                np.clip(
                    rng.normal(
                        1.0
                        + 5.8 * subjective_probability
                        + 0.35 * consequence_rating
                        + 0.30 * affect_rating
                        + 0.24 * dread_rating
                        + 0.20 * ambiguity_rating
                        - 0.18 * controllability_rating
                        - 0.10 * trust_rating
                        - 0.10 * perceived_benefit
                        + 0.35 * ce["loss"]
                        + 0.25 * risk_sensitivity,
                        0.9,
                    ),
                    0,
                    10,
                )
            )

            safe_logit = (
                -2.6
                + 0.45 * perceived_risk
                + 0.18 * consequence_rating
                + 0.14 * affect_rating
                + 0.16 * ce["loss"]
                - 0.10 * perceived_benefit
                - 0.08 * controllability_rating
                + rng.normal(0, 0.25)
            )
            choose_safe = int(rng.random() < logistic(np.array([safe_logit]))[0])

            protective_logit = (
                -2.3
                + 0.38 * perceived_risk
                + 0.14 * trust_rating
                + 0.12 * communication_clarity
                + 0.10 * controllability_rating
                - 0.11 * ambiguity_rating
                + 0.10 * ce["clarity"]
                + rng.normal(0, 0.25)
            )
            protective_action = int(rng.random() < logistic(np.array([protective_logit]))[0])

            confidence = float(
                np.clip(
                    rng.normal(
                        5.0
                        + 0.20 * communication_clarity
                        + 0.15 * trust_rating
                        - 0.20 * ambiguity_rating
                        + 0.15 * numeracy
                        + 0.20 * ce["ai"],
                        1.0,
                    ),
                    0,
                    10,
                )
            )

            rt_ms = int(
                np.clip(
                    np.exp(
                        math.log(1850)
                        + 0.045 * ambiguity_rating
                        + 0.035 * perceived_risk
                        + 0.025 * abs(subjective_probability - objective_probability) * 10
                        - 0.035 * communication_clarity
                        - 0.055 * ce["ai"]
                        + speed_factor
                        + rng.normal(0, 0.12)
                    ),
                    150,
                    120000,
                )
            )

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "domain": domain,
                    "trial": trial,
                    "scenario_id": scenario_id,
                    "objective_probability": round(objective_probability, 4),
                    "subjective_probability": round(subjective_probability, 4),
                    "consequence_rating": round(consequence_rating, 3),
                    "affect_rating": round(affect_rating, 3),
                    "dread_rating": round(dread_rating, 3),
                    "familiarity_rating": round(familiarity_rating, 3),
                    "controllability_rating": round(controllability_rating, 3),
                    "trust_rating": round(trust_rating, 3),
                    "ambiguity_rating": round(ambiguity_rating, 3),
                    "communication_clarity": round(communication_clarity, 3),
                    "perceived_benefit": round(perceived_benefit, 3),
                    "perceived_risk": round(perceived_risk, 3),
                    "choose_safe": choose_safe,
                    "protective_action": protective_action,
                    "rt_ms": rt_ms,
                    "confidence": round(confidence, 3),
                }
            )

    df = pd.DataFrame(rows)
    df["probability_distortion"] = df["subjective_probability"] - df["objective_probability"]
    df["risk_benefit_gap"] = df["perceived_risk"] - df["perceived_benefit"]
    return df


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if "probability_distortion" not in df.columns:
        df["probability_distortion"] = df["subjective_probability"] - df["objective_probability"]
    if "risk_benefit_gap" not in df.columns:
        df["risk_benefit_gap"] = df["perceived_risk"] - df["perceived_benefit"]

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("perceived_risk", "size"),
            participants=("participant", "nunique"),
            mean_objective_probability=("objective_probability", "mean"),
            mean_subjective_probability=("subjective_probability", "mean"),
            mean_probability_distortion=("probability_distortion", "mean"),
            mean_consequence=("consequence_rating", "mean"),
            mean_affect=("affect_rating", "mean"),
            mean_dread=("dread_rating", "mean"),
            mean_controllability=("controllability_rating", "mean"),
            mean_trust=("trust_rating", "mean"),
            mean_ambiguity=("ambiguity_rating", "mean"),
            mean_clarity=("communication_clarity", "mean"),
            mean_benefit=("perceived_benefit", "mean"),
            mean_perceived_risk=("perceived_risk", "mean"),
            safe_choice_rate=("choose_safe", "mean"),
            protective_action_rate=("protective_action", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_domain = (
        df.groupby("domain")
        .agg(
            n_trials=("perceived_risk", "size"),
            mean_perceived_risk=("perceived_risk", "mean"),
            mean_affect=("affect_rating", "mean"),
            mean_dread=("dread_rating", "mean"),
            mean_ambiguity=("ambiguity_rating", "mean"),
            mean_trust=("trust_rating", "mean"),
            safe_choice_rate=("choose_safe", "mean"),
            protective_action_rate=("protective_action", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_domain.to_csv(outputs / "summary_by_domain.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if "probability_distortion" not in df.columns:
        df["probability_distortion"] = df["subjective_probability"] - df["objective_probability"]
    if "risk_benefit_gap" not in df.columns:
        df["risk_benefit_gap"] = df["perceived_risk"] - df["perceived_benefit"]

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    risk_formula = (
        "perceived_risk ~ condition + domain + objective_probability + subjective_probability + "
        "consequence_rating + affect_rating + dread_rating + familiarity_rating + "
        "controllability_rating + trust_rating + ambiguity_rating + communication_clarity + perceived_benefit"
    )
    risk_model = smf.ols(risk_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Perceived-risk model ===\n")
    model_text.append(str(risk_model.summary()))

    distortion_formula = (
        "probability_distortion ~ condition + domain + objective_probability + affect_rating + "
        "dread_rating + ambiguity_rating + communication_clarity + trust_rating + confidence"
    )
    distortion_model = smf.ols(distortion_formula, data=df).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Probability-distortion model ===\n")
    model_text.append(str(distortion_model.summary()))

    safe_formula = (
        "choose_safe ~ condition + domain + perceived_risk + consequence_rating + affect_rating + "
        "dread_rating + controllability_rating + trust_rating + ambiguity_rating + perceived_benefit"
    )
    safe_model = smf.glm(safe_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Safe-choice logistic model ===\n")
    model_text.append(str(safe_model.summary()))

    action_formula = (
        "protective_action ~ condition + domain + perceived_risk + trust_rating + "
        "communication_clarity + controllability_rating + ambiguity_rating + confidence"
    )
    action_model = smf.glm(action_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Protective-action logistic model ===\n")
    model_text.append(str(action_model.summary()))

    clarity_formula = (
        "communication_clarity ~ condition + domain + trust_rating + ambiguity_rating + "
        "objective_probability + consequence_rating + affect_rating"
    )
    clarity_model = smf.ols(clarity_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Communication-clarity model ===\n")
    model_text.append(str(clarity_model.summary()))

    rt_df = df[df["rt_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["rt_ms"])
    rt_formula = (
        "log_rt ~ condition + domain + perceived_risk + ambiguity_rating + "
        "communication_clarity + confidence + choose_safe + protective_action"
    )
    rt_model = smf.ols(rt_formula, data=rt_df).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": risk_model.params.index,
            "perceived_risk_coef": risk_model.params.values,
            "perceived_risk_se": risk_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "perceived_risk_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/risk_perception_trials.csv"))
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
        default_input = Path("data/risk_perception_trials.csv")
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
