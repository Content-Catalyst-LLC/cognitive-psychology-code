#!/usr/bin/env python3
"""
Perception research model.

This script can:
1. Generate synthetic perceptual trial data.
2. Estimate psychometric curves, signal detection, perceptual thresholds,
   visual-search slopes, prediction-error effects, attention/context effects,
   confidence, and response-time models.
3. Save researcher-readable summaries to outputs/.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from typing import Dict

import numpy as np
import pandas as pd
from scipy.stats import norm

try:
    import statsmodels.formula.api as smf
    import statsmodels.api as sm
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False


CONDITIONS = [
    "control", "low_contrast", "high_contrast", "attention_cued", "attention_uncued",
    "predictive_context", "neutral_context", "multisensory_congruent",
    "multisensory_incongruent", "interface_salient"
]
DOMAINS = ["general", "visual", "auditory", "tactile", "multisensory", "interface", "medical", "safety", "ai"]
MODALITIES = ["visual", "auditory", "tactile", "multisensory", "interface"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def hautus_rate(k: float, n: float) -> float:
    return (k + 0.5) / (n + 1.0)


def compute_sdt(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (participant, condition), g in df.groupby(["participant", "condition"]):
        hits = int(((g["signal_present"] == 1) & (g["response_yes"] == 1)).sum())
        misses = int(((g["signal_present"] == 1) & (g["response_yes"] == 0)).sum())
        fas = int(((g["signal_present"] == 0) & (g["response_yes"] == 1)).sum())
        crs = int(((g["signal_present"] == 0) & (g["response_yes"] == 0)).sum())
        hit_rate = hautus_rate(hits, hits + misses)
        fa_rate = hautus_rate(fas, fas + crs)
        dprime = norm.ppf(hit_rate) - norm.ppf(fa_rate)
        criterion = -0.5 * (norm.ppf(hit_rate) + norm.ppf(fa_rate))
        rows.append({
            "participant": participant,
            "condition": condition,
            "hits": hits,
            "misses": misses,
            "false_alarms": fas,
            "correct_rejections": crs,
            "hit_rate": hit_rate,
            "false_alarm_rate": fa_rate,
            "dprime": dprime,
            "criterion": criterion,
        })
    return pd.DataFrame(rows)


def generate_dataset(n_participants: int = 320, trials_per_participant: int = 18, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"evidence": 0.0, "attention": 0.0, "context": 0.0, "noise": 0.0, "salience": 0.0},
        "low_contrast": {"evidence": -1.4, "attention": 0.0, "context": 0.0, "noise": 1.8, "salience": -0.8},
        "high_contrast": {"evidence": 1.5, "attention": 0.0, "context": 0.2, "noise": -1.0, "salience": 0.6},
        "attention_cued": {"evidence": 0.4, "attention": 2.5, "context": 0.4, "noise": -0.4, "salience": 0.5},
        "attention_uncued": {"evidence": -0.5, "attention": -1.6, "context": -0.2, "noise": 0.8, "salience": -0.3},
        "predictive_context": {"evidence": 0.2, "attention": 0.3, "context": 2.8, "noise": -0.3, "salience": 0.2},
        "neutral_context": {"evidence": 0.0, "attention": 0.0, "context": 0.0, "noise": 0.0, "salience": 0.0},
        "multisensory_congruent": {"evidence": 0.7, "attention": 0.4, "context": 1.2, "noise": -0.8, "salience": 0.4},
        "multisensory_incongruent": {"evidence": -0.4, "attention": 0.1, "context": -1.0, "noise": 1.8, "salience": -0.2},
        "interface_salient": {"evidence": 0.8, "attention": 1.3, "context": 0.8, "noise": -0.5, "salience": 2.6},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        sensitivity = rng.normal(0, 0.55)
        bias = rng.normal(0, 0.35)
        speed = rng.normal(0, 0.14)
        base_threshold = float(np.clip(rng.normal(0.25 - 0.25 * sensitivity, 0.35), -1.5, 2.0))

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            modality = rng.choice(MODALITIES)
            if condition.startswith("multisensory"):
                modality = "multisensory"
                domain = "multisensory"
            if condition == "interface_salient":
                modality = "interface"
                domain = "interface"

            ce = condition_effects[condition]
            signal_present = int(rng.random() < 0.58)
            stimulus_id = f"S{trial:03d}_{participant}"

            stimulus_level = float(np.clip(rng.normal(0.4 + ce["evidence"] + 1.0 * signal_present, 1.4), -10, 10))
            noise_level = float(np.clip(rng.normal(4.0 + ce["noise"] + 0.35 * (domain in ["medical", "safety", "ai"]), 1.1), 0, 10))
            prior_expectation = float(np.clip(rng.normal(4.8 + ce["context"] + 0.8 * signal_present, 1.2), 0, 10))
            cue_quality = float(np.clip(rng.normal(5.0 + 0.45 * stimulus_level + 0.35 * ce["context"] - 0.22 * noise_level, 1.0), 0, 10))
            attention_gain = float(np.clip(rng.normal(5.0 + ce["attention"] + 0.25 * ce["salience"], 1.0), 0, 10))
            context_strength = float(np.clip(rng.normal(4.5 + ce["context"], 1.2), 0, 10))
            multisensory_congruence = float(np.clip(rng.normal(0.75 if condition == "multisensory_congruent" else 0.25 if condition == "multisensory_incongruent" else 0.0, 0.12), 0, 1))
            visual_search_set_size = int(np.clip(round(rng.normal(10 + 6 * (domain in ["interface", "medical", "safety"]), 4)), 1, 40))
            distractor_similarity = float(np.clip(rng.normal(3.5 + 2.5 * (condition in ["low_contrast", "multisensory_incongruent"]) + 0.12 * visual_search_set_size, 1.1), 0, 10))
            perceptual_learning_block = int(np.clip(round(rng.uniform(1, 7)), 1, 8))
            interface_salience = float(np.clip(rng.normal(4.0 + ce["salience"] + 0.30 * attention_gain, 1.1), 0, 10))
            prediction_error = float(np.clip(abs(stimulus_level - (prior_expectation - 5) * 0.45) + 0.18 * noise_level - 0.08 * context_strength, 0, 10))
            perceptual_threshold = float(np.clip(base_threshold + 0.10 * noise_level + 0.08 * distractor_similarity - 0.10 * attention_gain - 0.05 * perceptual_learning_block, -3, 6))
            sensory_evidence = float(np.clip(stimulus_level - perceptual_threshold + 0.18 * cue_quality + 0.12 * attention_gain + 0.10 * context_strength - 0.20 * noise_level + 0.35 * multisensory_congruence + rng.normal(0, 0.35), -10, 10))

            decision_latent = (
                -0.25
                + 0.85 * sensory_evidence
                + 0.09 * prior_expectation
                + 0.08 * cue_quality
                + 0.07 * attention_gain
                + 0.05 * context_strength
                - 0.10 * noise_level
                - 0.06 * distractor_similarity
                + 0.25 * multisensory_congruence
                + bias
                + rng.normal(0, 0.30)
            )
            response_yes = int(rng.random() < logistic(np.array([decision_latent]))[0])
            correct = int((signal_present == 1 and response_yes == 1) or (signal_present == 0 and response_yes == 0))

            confidence = float(np.clip(0.42 + 0.25 * abs(decision_latent) + 0.10 * correct + 0.03 * cue_quality - 0.03 * noise_level + rng.normal(0, 0.08), 0, 1))
            response_time_ms = int(np.clip(np.exp(math.log(950) - 0.065 * abs(sensory_evidence) + 0.040 * noise_level + 0.030 * distractor_similarity + 0.012 * visual_search_set_size - 0.030 * attention_gain - 0.025 * interface_salience + speed + rng.normal(0, 0.14)), 150, 60000))

            rows.append({
                "participant": participant,
                "condition": condition,
                "domain": domain,
                "trial": trial,
                "stimulus_id": stimulus_id,
                "modality": modality,
                "stimulus_level": round(stimulus_level, 3),
                "signal_present": signal_present,
                "response_yes": response_yes,
                "correct": correct,
                "sensory_evidence": round(sensory_evidence, 3),
                "prior_expectation": round(prior_expectation, 3),
                "cue_quality": round(cue_quality, 3),
                "attention_gain": round(attention_gain, 3),
                "context_strength": round(context_strength, 3),
                "noise_level": round(noise_level, 3),
                "prediction_error": round(prediction_error, 3),
                "perceptual_threshold": round(perceptual_threshold, 3),
                "confidence": round(confidence, 4),
                "response_time_ms": response_time_ms,
                "multisensory_congruence": round(multisensory_congruence, 4),
                "visual_search_set_size": visual_search_set_size,
                "distractor_similarity": round(distractor_similarity, 3),
                "perceptual_learning_block": perceptual_learning_block,
                "interface_salience": round(interface_salience, 3),
            })

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("correct", "size"),
            participants=("participant", "nunique"),
            correct_rate=("correct", "mean"),
            yes_rate=("response_yes", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
            mean_sensory_evidence=("sensory_evidence", "mean"),
            mean_prediction_error=("prediction_error", "mean"),
            mean_threshold=("perceptual_threshold", "mean"),
            mean_noise=("noise_level", "mean"),
            mean_attention_gain=("attention_gain", "mean"),
            mean_context_strength=("context_strength", "mean"),
        )
        .reset_index()
    )

    by_stimulus = (
        df.groupby(["condition", "stimulus_level"])
        .agg(
            n_trials=("response_yes", "size"),
            yes_rate=("response_yes", "mean"),
            correct_rate=("correct", "mean"),
            mean_rt=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    sdt = compute_sdt(df)

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_stimulus.to_csv(outputs / "psychometric_summary_by_stimulus.csv", index=False)
    sdt.to_csv(outputs / "signal_detection_by_participant_condition.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    yes_model = smf.glm(
        "response_yes ~ condition + modality + stimulus_level + signal_present + sensory_evidence + "
        "prior_expectation + cue_quality + attention_gain + context_strength + noise_level + "
        "prediction_error + multisensory_congruence + interface_salience",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Perceptual response logistic model ===\n")
    model_text.append(str(yes_model.summary()))

    acc_model = smf.glm(
        "correct ~ condition + modality + stimulus_level + sensory_evidence + cue_quality + "
        "attention_gain + context_strength + noise_level + prediction_error + perceptual_threshold + "
        "visual_search_set_size + distractor_similarity + perceptual_learning_block + interface_salience",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Perceptual accuracy logistic model ===\n")
    model_text.append(str(acc_model.summary()))

    threshold_model = smf.ols(
        "perceptual_threshold ~ condition + modality + noise_level + attention_gain + cue_quality + "
        "context_strength + visual_search_set_size + distractor_similarity + perceptual_learning_block",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Perceptual-threshold model ===\n")
    model_text.append(str(threshold_model.summary()))

    prediction_model = smf.ols(
        "prediction_error ~ condition + modality + stimulus_level + prior_expectation + cue_quality + "
        "context_strength + noise_level + multisensory_congruence",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Prediction-error model ===\n")
    model_text.append(str(prediction_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_rt"] = np.log(rt_df["response_time_ms"])
    rt_model = smf.ols(
        "log_rt ~ condition + modality + correct + confidence + sensory_evidence + noise_level + "
        "attention_gain + prediction_error + visual_search_set_size + distractor_similarity + interface_salience",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    pd.DataFrame({"term": yes_model.params.index, "response_yes_coef": yes_model.params.values, "response_yes_se": yes_model.bse.values}).to_csv(outputs / "response_yes_model_coefficients.csv", index=False)
    pd.DataFrame({"term": acc_model.params.index, "accuracy_coef": acc_model.params.values, "accuracy_se": acc_model.bse.values}).to_csv(outputs / "accuracy_model_coefficients.csv", index=False)
    pd.DataFrame({"term": threshold_model.params.index, "threshold_coef": threshold_model.params.values, "threshold_se": threshold_model.bse.values}).to_csv(outputs / "threshold_model_coefficients.csv", index=False)
    pd.DataFrame({"term": rt_model.params.index, "response_time_coef": rt_model.params.values, "response_time_se": rt_model.bse.values}).to_csv(outputs / "response_time_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/perception_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=320)
    parser.add_argument("--trials", type=int, default=18)
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
        default_input = Path("data/perception_trials.csv")
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
