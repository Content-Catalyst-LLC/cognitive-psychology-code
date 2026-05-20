#!/usr/bin/env python3
"""
Attention research model.

This script can:
1. Generate synthetic attention trial data.
2. Estimate signal detection metrics, cueing effects, vigilance decrement,
   response-time models, accuracy models, lapse models, and divided-attention costs.
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


CONDITIONS = ["control", "valid_cue", "invalid_cue", "neutral_cue", "high_load", "low_load", "distraction", "dual_task", "vigilance", "interface_alert"]
DOMAINS = ["general", "visual", "auditory", "multisensory", "interface", "driving", "medical", "education", "ai", "safety"]
TASK_TYPES = ["cueing", "visual_search", "cpt", "flanker", "stroop", "dual_task", "attentional_blink", "monitoring", "interface"]
CUE_VALIDITIES = ["valid", "neutral", "invalid", "none"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def hautus_rate(k: float, n: float) -> float:
    return (k + 0.5) / (n + 1.0)


def compute_sdt(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (participant, condition), g in df.groupby(["participant", "condition"]):
        hits = int(((g["target_present"] == 1) & (g["response_yes"] == 1)).sum())
        misses = int(((g["target_present"] == 1) & (g["response_yes"] == 0)).sum())
        fas = int(((g["target_present"] == 0) & (g["response_yes"] == 1)).sum())
        crs = int(((g["target_present"] == 0) & (g["response_yes"] == 0)).sum())
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


def generate_dataset(n_participants: int = 320, trials_per_participant: int = 24, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"salience": 0.0, "goal": 0.0, "distractor": 0.0, "perceptual": 0.0, "executive": 0.0, "rt": 0.0, "lapse": 0.0},
        "valid_cue": {"salience": 0.4, "goal": 1.8, "distractor": -0.4, "perceptual": -0.2, "executive": -0.2, "rt": -0.12, "lapse": -0.05},
        "invalid_cue": {"salience": -0.1, "goal": 0.6, "distractor": 0.8, "perceptual": 0.3, "executive": 0.7, "rt": 0.15, "lapse": 0.06},
        "neutral_cue": {"salience": 0.0, "goal": 0.0, "distractor": 0.0, "perceptual": 0.0, "executive": 0.0, "rt": 0.03, "lapse": 0.0},
        "high_load": {"salience": -0.2, "goal": 0.2, "distractor": 1.8, "perceptual": 2.2, "executive": 1.8, "rt": 0.16, "lapse": 0.09},
        "low_load": {"salience": 0.2, "goal": 0.3, "distractor": -1.2, "perceptual": -1.4, "executive": -1.0, "rt": -0.06, "lapse": -0.04},
        "distraction": {"salience": 0.1, "goal": -0.2, "distractor": 3.0, "perceptual": 0.8, "executive": 1.3, "rt": 0.14, "lapse": 0.12},
        "dual_task": {"salience": -0.1, "goal": 0.0, "distractor": 1.2, "perceptual": 1.0, "executive": 2.8, "rt": 0.18, "lapse": 0.13},
        "vigilance": {"salience": -0.2, "goal": 0.4, "distractor": 0.4, "perceptual": 0.8, "executive": 1.4, "rt": 0.12, "lapse": 0.16},
        "interface_alert": {"salience": 2.8, "goal": 1.0, "distractor": 0.6, "perceptual": 0.4, "executive": 0.5, "rt": -0.08, "lapse": -0.02},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        sensitivity_trait = rng.normal(0, 0.55)
        caution_trait = rng.normal(0, 0.35)
        speed_trait = rng.normal(0, 0.15)
        vigilance_trait = rng.normal(0, 0.55)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            ce = condition_effects[condition]
            domain = rng.choice(DOMAINS)
            task_type = rng.choice(TASK_TYPES)

            if condition in ["valid_cue", "invalid_cue", "neutral_cue"]:
                task_type = "cueing"
                cue_validity = condition.replace("_cue", "")
            elif condition == "interface_alert":
                task_type = "interface"
                cue_validity = "valid"
                domain = "interface"
            else:
                cue_validity = rng.choice(CUE_VALIDITIES, p=[0.18, 0.22, 0.16, 0.44])

            if condition == "vigilance":
                task_type = "cpt"
                domain = rng.choice(["safety", "medical", "driving", "interface"])

            block = int(np.clip(math.ceil(trial / max(1, trials_per_participant / 8)), 1, 8))
            stimulus_id = f"A{trial:03d}_{participant}"
            target_present = int(rng.random() < (0.28 if condition == "vigilance" else 0.56))

            salience = float(np.clip(rng.normal(5.0 + ce["salience"] + 0.8 * target_present, 1.1), 0, 10))
            goal_relevance = float(np.clip(rng.normal(5.5 + ce["goal"] + 0.8 * target_present, 1.0), 0, 10))
            distractor_load = float(np.clip(rng.normal(3.0 + ce["distractor"] + 0.5 * (domain in ["interface", "driving", "medical"]), 1.1), 0, 10))
            perceptual_load = float(np.clip(rng.normal(3.2 + ce["perceptual"] + 0.35 * distractor_load, 1.0), 0, 10))
            executive_load = float(np.clip(rng.normal(3.0 + ce["executive"] + 0.35 * (task_type in ["flanker", "stroop", "dual_task"]), 1.0), 0, 10))
            task_switch = int(rng.random() < (0.12 + 0.12 * (condition in ["dual_task", "distraction"])))
            conflict = float(np.clip(rng.normal(1.8 + 0.55 * distractor_load + 0.45 * task_switch + 0.5 * (task_type in ["flanker", "stroop"]), 1.0), 0, 10))
            interface_salience = float(np.clip(rng.normal(4.0 + 2.8 * (condition == "interface_alert") + 0.25 * salience, 1.0), 0, 10))
            notification_load = float(np.clip(rng.normal(2.0 + 4.0 * (domain == "interface") + 1.3 * (condition in ["distraction", "dual_task"]), 1.2), 0, 10))
            divided_attention_cost = float(np.clip(0.03 + 0.04 * executive_load + 0.035 * distractor_load + 0.12 * (condition == "dual_task") + rng.normal(0, 0.025), 0, 1))

            vigilance_state = float(np.clip(8.2 + vigilance_trait - 0.40 * block - 0.18 * executive_load - 0.14 * notification_load - 0.25 * (condition == "vigilance") + rng.normal(0, 0.45), 0, 10))
            lapse_probability = float(np.clip(logistic(np.array([
                -2.6 + 0.34 * block + 0.20 * executive_load + 0.18 * distractor_load + 0.16 * notification_load - 0.28 * vigilance_state + ce["lapse"]
            ]))[0], 0, 1))

            evidence = (
                0.38 * salience
                + 0.34 * goal_relevance
                + 0.22 * interface_salience
                + 0.65 * target_present
                - 0.24 * distractor_load
                - 0.20 * perceptual_load
                - 0.18 * executive_load
                - 0.14 * conflict
                - 1.35 * (rng.random() < lapse_probability)
                + sensitivity_trait
                + rng.normal(0, 0.35)
            )

            response_bias = -0.10 + 0.16 * salience + 0.10 * goal_relevance - 0.18 * executive_load + 0.12 * (condition == "interface_alert") - caution_trait
            p_yes = logistic(np.array([evidence + response_bias]))[0]
            response_yes = int(rng.random() < p_yes)
            correct = int((target_present == 1 and response_yes == 1) or (target_present == 0 and response_yes == 0))

            confidence = float(np.clip(0.38 + 0.18 * abs(evidence) + 0.12 * correct + 0.03 * salience + 0.02 * goal_relevance - 0.03 * distractor_load - 0.03 * lapse_probability + rng.normal(0, 0.08), 0, 1))
            cue_rt = -0.12 * (cue_validity == "valid") + 0.12 * (cue_validity == "invalid") + 0.03 * (cue_validity == "neutral")
            rt = int(np.clip(np.exp(math.log(720) + ce["rt"] + cue_rt + 0.032 * distractor_load + 0.030 * executive_load + 0.028 * conflict + 0.040 * block + 0.10 * task_switch - 0.030 * salience - 0.035 * goal_relevance - 0.025 * interface_salience + 0.18 * (1 - correct) + speed_trait + rng.normal(0, 0.14)), 150, 60000))

            rows.append({
                "participant": participant,
                "condition": condition,
                "domain": domain,
                "trial": trial,
                "block": block,
                "stimulus_id": stimulus_id,
                "cue_validity": cue_validity,
                "task_type": task_type,
                "target_present": target_present,
                "response_yes": response_yes,
                "correct": correct,
                "rt": rt,
                "salience": round(salience, 3),
                "goal_relevance": round(goal_relevance, 3),
                "distractor_load": round(distractor_load, 3),
                "perceptual_load": round(perceptual_load, 3),
                "executive_load": round(executive_load, 3),
                "task_switch": task_switch,
                "conflict": round(conflict, 3),
                "vigilance_state": round(vigilance_state, 3),
                "lapse_probability": round(lapse_probability, 4),
                "confidence": round(confidence, 4),
                "interface_salience": round(interface_salience, 3),
                "notification_load": round(notification_load, 3),
                "divided_attention_cost": round(divided_attention_cost, 4),
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
            mean_rt=("rt", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_lapse_probability=("lapse_probability", "mean"),
            mean_vigilance_state=("vigilance_state", "mean"),
            mean_distractor_load=("distractor_load", "mean"),
            mean_executive_load=("executive_load", "mean"),
            mean_divided_attention_cost=("divided_attention_cost", "mean"),
        )
        .reset_index()
    )

    by_cue = (
        df.groupby(["condition", "cue_validity"])
        .agg(
            n_trials=("correct", "size"),
            correct_rate=("correct", "mean"),
            mean_rt=("rt", "mean"),
            mean_confidence=("confidence", "mean"),
        )
        .reset_index()
    )

    by_block = (
        df.groupby(["condition", "block"])
        .agg(
            n_trials=("correct", "size"),
            correct_rate=("correct", "mean"),
            yes_rate=("response_yes", "mean"),
            mean_rt=("rt", "mean"),
            mean_lapse_probability=("lapse_probability", "mean"),
            mean_vigilance_state=("vigilance_state", "mean"),
        )
        .reset_index()
    )

    sdt = compute_sdt(df)

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_cue.to_csv(outputs / "summary_by_cue_validity.csv", index=False)
    by_block.to_csv(outputs / "summary_by_block.csv", index=False)
    sdt.to_csv(outputs / "signal_detection_by_participant_condition.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []
    df = df.copy()
    df["block_z"] = (df["block"] - df["block"].mean()) / df["block"].std()
    df["log_rt"] = np.log(df["rt"])

    acc_model = smf.glm(
        "correct ~ condition + cue_validity + task_type + block_z + salience + goal_relevance + "
        "distractor_load + perceptual_load + executive_load + task_switch + conflict + "
        "vigilance_state + interface_salience + notification_load",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Attention accuracy logistic model ===\n")
    model_text.append(str(acc_model.summary()))

    response_model = smf.glm(
        "response_yes ~ condition + cue_validity + target_present + salience + goal_relevance + "
        "distractor_load + perceptual_load + executive_load + conflict + vigilance_state + "
        "lapse_probability + confidence + interface_salience",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Target-present response model ===\n")
    model_text.append(str(response_model.summary()))

    rt_df = df[(df["rt"] >= 150) & (df["correct"] == 1)].copy()
    rt_model = smf.ols(
        "log_rt ~ condition + cue_validity + task_type + block_z + salience + goal_relevance + "
        "distractor_load + perceptual_load + executive_load + task_switch + conflict + "
        "vigilance_state + confidence + interface_salience + notification_load",
        data=rt_df,
    ).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    model_text.append("\n\n=== Response-time model for correct trials ===\n")
    model_text.append(str(rt_model.summary()))

    vigilance_model = smf.glm(
        "correct ~ block_z * condition + vigilance_state + lapse_probability + distractor_load + executive_load",
        data=df,
        family=sm.families.Binomial(),
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Vigilance decrement model ===\n")
    model_text.append(str(vigilance_model.summary()))

    lapse_model = smf.ols(
        "lapse_probability ~ condition + block_z + vigilance_state + distractor_load + executive_load + "
        "notification_load + divided_attention_cost",
        data=df,
    ).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
    model_text.append("\n\n=== Lapse probability model ===\n")
    model_text.append(str(lapse_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    pd.DataFrame({"term": acc_model.params.index, "accuracy_coef": acc_model.params.values, "accuracy_se": acc_model.bse.values}).to_csv(outputs / "accuracy_model_coefficients.csv", index=False)
    pd.DataFrame({"term": response_model.params.index, "response_yes_coef": response_model.params.values, "response_yes_se": response_model.bse.values}).to_csv(outputs / "response_yes_model_coefficients.csv", index=False)
    pd.DataFrame({"term": rt_model.params.index, "response_time_coef": rt_model.params.values, "response_time_se": rt_model.bse.values}).to_csv(outputs / "response_time_model_coefficients.csv", index=False)
    pd.DataFrame({"term": vigilance_model.params.index, "vigilance_coef": vigilance_model.params.values, "vigilance_se": vigilance_model.bse.values}).to_csv(outputs / "vigilance_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/attention_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=320)
    parser.add_argument("--trials", type=int, default=24)
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
        default_input = Path("data/attention_trials.csv")
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
