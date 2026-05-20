#!/usr/bin/env python3
"""
Sensory memory research model.

This script can:
1. Generate synthetic sensory-memory trial data.
2. Estimate models for trace decay, report accuracy, selection probability,
   working-memory transfer, response time, confidence, and perceptual continuity.
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


MODALITIES = ["visual", "auditory", "tactile", "multimodal"]
CONDITIONS = ["whole_report", "partial_report", "valid_cue", "invalid_cue", "neutral_cue", "mask_early", "mask_late", "no_mask"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def decay_trace(delay_ms: np.ndarray, s0: float, lambda_per_ms: float) -> np.ndarray:
    return s0 * np.exp(-lambda_per_ms * delay_ms)


def generate_dataset(n_participants: int = 220, trials_per_participant: int = 16, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    modality_params: Dict[str, Dict[str, float]] = {
        "visual": {"s0": 0.95, "lambda": 0.0048, "duration": 50, "array": 12, "continuity": 6.8},
        "auditory": {"s0": 0.92, "lambda": 0.00055, "duration": 300, "array": 9, "continuity": 7.8},
        "tactile": {"s0": 0.82, "lambda": 0.00125, "duration": 200, "array": 6, "continuity": 7.2},
        "multimodal": {"s0": 0.90, "lambda": 0.00110, "duration": 150, "array": 9, "continuity": 8.0},
    }

    condition_effects: Dict[str, Dict[str, float]] = {
        "whole_report": {"priority": 2.8, "cue": 0.0, "mask": 0, "delay_shift": 0},
        "partial_report": {"priority": 7.6, "cue": 1.0, "mask": 0, "delay_shift": 0},
        "valid_cue": {"priority": 8.2, "cue": 1.0, "mask": 0, "delay_shift": 0},
        "invalid_cue": {"priority": 3.2, "cue": 0.0, "mask": 0, "delay_shift": 0},
        "neutral_cue": {"priority": 5.4, "cue": 0.5, "mask": 0, "delay_shift": 0},
        "mask_early": {"priority": 6.8, "cue": 1.0, "mask": 1, "delay_shift": 0},
        "mask_late": {"priority": 6.8, "cue": 1.0, "mask": 1, "delay_shift": 200},
        "no_mask": {"priority": 6.4, "cue": 0.7, "mask": 0, "delay_shift": 0},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        sensory_sensitivity = rng.normal(0, 0.35)
        attentional_control = rng.normal(0, 0.45)
        speed_factor = rng.normal(0, 0.14)

        for trial in range(1, trials_per_participant + 1):
            modality = rng.choice(MODALITIES, p=[0.38, 0.30, 0.20, 0.12])
            condition = rng.choice(CONDITIONS)
            mp = modality_params[modality]
            ce = condition_effects[condition]

            if modality == "visual":
                base_delay = rng.choice([0, 50, 100, 150, 250, 400, 700])
            elif modality == "auditory":
                base_delay = rng.choice([0, 250, 500, 1000, 2000, 3500, 5000])
            elif modality == "tactile":
                base_delay = rng.choice([0, 150, 300, 600, 1000, 1600, 2400])
            else:
                base_delay = rng.choice([0, 100, 250, 500, 1000, 2000, 3500])

            cue_delay_ms = int(base_delay + ce["delay_shift"])
            stimulus_duration_ms = int(np.clip(rng.normal(mp["duration"], max(10, mp["duration"] * 0.08)), 10, 1000))
            array_size = int(max(1, round(rng.normal(mp["array"], 1.5))))
            cue_validity = float(np.clip(ce["cue"] + rng.normal(0, 0.05), 0, 1))
            mask_present = int(ce["mask"])

            s0 = np.clip(mp["s0"] + 0.08 * sensory_sensitivity + rng.normal(0, 0.03), 0.05, 1.0)
            lambda_per_ms = np.clip(mp["lambda"] * (1.0 + 0.15 * rng.normal()), 0.00005, 0.020)
            trace_strength = float(np.clip(decay_trace(np.array([cue_delay_ms]), s0, lambda_per_ms)[0], 0, 1))
            if condition == "mask_early":
                trace_strength *= 0.48
            elif condition == "mask_late":
                trace_strength *= 0.72

            salience = float(np.clip(rng.normal(5.8 + 1.2 * (modality == "multimodal") + 0.4 * sensory_sensitivity, 1.0), 0, 10))
            attentional_priority = float(np.clip(rng.normal(ce["priority"] + 0.8 * attentional_control, 0.9), 0, 10))

            selection_logit = (
                -1.2
                + 3.1 * trace_strength
                + 0.18 * salience
                + 0.28 * attentional_priority
                + 0.55 * cue_validity
                - 0.10 * array_size
                - 0.45 * mask_present
                + rng.normal(0, 0.20)
            )
            selection_probability = float(logistic(np.array([selection_logit]))[0])

            correct = int(rng.random() < selection_probability)
            wm_transfer_prob = logistic(np.array([
                -1.6 + 2.4 * trace_strength + 0.22 * attentional_priority + 0.60 * correct + 0.30 * cue_validity - 0.38 * mask_present
            ]))[0]
            wm_transfer = int(rng.random() < wm_transfer_prob)

            if condition == "whole_report":
                max_report = min(array_size, 12)
                report_score = np.clip(rng.normal(3.5 + 2.5 * correct + 0.10 * salience - 0.08 * array_size, 1.2), 0, max_report)
            else:
                max_report = max(1, min(4, array_size))
                report_score = np.clip(rng.normal(1.0 + 2.2 * correct + 0.08 * attentional_priority, 0.8), 0, max_report)

            rt_ms = int(np.clip(
                np.exp(
                    math.log(900)
                    + 0.00012 * cue_delay_ms
                    + 0.025 * array_size
                    - 0.12 * correct
                    + 0.060 * mask_present
                    - 0.025 * attentional_priority
                    + speed_factor
                    + rng.normal(0, 0.12)
                ),
                100,
                20000,
            ))

            confidence = float(np.clip(rng.normal(4.6 + 3.0 * trace_strength + 0.9 * correct + 0.20 * attentional_priority - 0.35 * mask_present, 0.9), 0, 10))
            perceptual_continuity = float(np.clip(rng.normal(mp["continuity"] + 1.2 * trace_strength - 0.35 * mask_present + 0.35 * wm_transfer, 0.9), 0, 10))

            rows.append(
                {
                    "participant": participant,
                    "modality": modality,
                    "condition": condition,
                    "trial": trial,
                    "stimulus_id": f"SM{trial:03d}_{participant}",
                    "cue_delay_ms": cue_delay_ms,
                    "stimulus_duration_ms": stimulus_duration_ms,
                    "array_size": array_size,
                    "cue_validity": round(cue_validity, 3),
                    "mask_present": mask_present,
                    "trace_strength": round(trace_strength, 4),
                    "salience": round(salience, 3),
                    "attentional_priority": round(attentional_priority, 3),
                    "report_score": round(float(report_score), 3),
                    "correct": correct,
                    "selection_probability": round(selection_probability, 4),
                    "wm_transfer": wm_transfer,
                    "rt_ms": rt_ms,
                    "confidence": round(confidence, 3),
                    "perceptual_continuity": round(perceptual_continuity, 3),
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_modality_delay = (
        df.groupby(["modality", "cue_delay_ms"])
        .agg(
            n_trials=("correct", "size"),
            accuracy=("correct", "mean"),
            mean_report=("report_score", "mean"),
            mean_trace=("trace_strength", "mean"),
            mean_selection=("selection_probability", "mean"),
            wm_transfer_rate=("wm_transfer", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("correct", "size"),
            participants=("participant", "nunique"),
            accuracy=("correct", "mean"),
            mean_report=("report_score", "mean"),
            mean_trace=("trace_strength", "mean"),
            wm_transfer_rate=("wm_transfer", "mean"),
            mean_rt_ms=("rt_ms", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_perceptual_continuity=("perceptual_continuity", "mean"),
        )
        .reset_index()
    )

    by_modality_delay.to_csv(outputs / "summary_by_modality_delay.csv", index=False)
    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)


def exponential_decay(x, a, lamb):
    return a * np.exp(-lamb * x)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels/scipy are not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    acc_formula = (
        "correct ~ cue_delay_ms * modality + condition + stimulus_duration_ms + array_size + "
        "cue_validity + mask_present + trace_strength + salience + attentional_priority"
    )
    acc_model = smf.glm(acc_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Correct-report logistic model ===\n")
    model_text.append(str(acc_model.summary()))

    report_formula = (
        "report_score ~ cue_delay_ms * modality + condition + array_size + "
        "cue_validity + mask_present + trace_strength + salience + attentional_priority"
    )
    report_model = smf.ols(report_formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Report-score model ===\n")
    model_text.append(str(report_model.summary()))

    transfer_formula = (
        "wm_transfer ~ cue_delay_ms + modality + condition + trace_strength + correct + "
        "cue_validity + attentional_priority + mask_present"
    )
    transfer_model = smf.glm(transfer_formula, data=df, family=sm.families.Binomial()).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Working-memory transfer model ===\n")
    model_text.append(str(transfer_model.summary()))

    rt_df = df[df["rt_ms"] >= 100].copy()
    rt_df["log_rt"] = np.log(rt_df["rt_ms"])
    rt_formula = (
        "log_rt ~ cue_delay_ms * modality + condition + array_size + correct + "
        "mask_present + attentional_priority + confidence"
    )
    rt_model = smf.ols(rt_formula, data=rt_df).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model ===\n")
    model_text.append(str(rt_model.summary()))

    continuity_formula = (
        "perceptual_continuity ~ modality + condition + trace_strength + wm_transfer + "
        "mask_present + cue_delay_ms + confidence"
    )
    continuity_model = smf.ols(continuity_formula, data=df).fit(
        cov_type="cluster", cov_kwds={"groups": df["participant"]}
    )
    model_text.append("\n\n=== Perceptual-continuity model ===\n")
    model_text.append(str(continuity_model.summary()))

    decay_rows = []
    for modality, group in df.groupby("modality"):
        summary = group.groupby("cue_delay_ms")["correct"].mean().reset_index()
        summary = summary[summary["correct"] > 0]
        try:
            params, _ = curve_fit(
                exponential_decay,
                summary["cue_delay_ms"].values.astype(float),
                summary["correct"].values.astype(float),
                p0=[0.9, 0.001],
                maxfev=10000,
            )
            decay_rows.append({"modality": modality, "a": params[0], "lambda": params[1]})
        except Exception as exc:
            decay_rows.append({"modality": modality, "a": np.nan, "lambda": np.nan, "error": str(exc)})

    pd.DataFrame(decay_rows).to_csv(outputs / "decay_parameter_estimates.csv", index=False)

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": report_model.params.index,
            "report_score_coef": report_model.params.values,
            "report_score_se": report_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "report_score_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/sensory_memory_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=220)
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
        default_input = Path("data/sensory_memory_trials.csv")
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
