#!/usr/bin/env python3
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

CONDITIONS = ["control", "deep_encoding", "shallow_encoding", "retrieval_practice", "restudy", "spaced", "massed", "misinformation", "source_monitoring", "ai_supported"]
DOMAINS = ["general", "verbal", "visual", "spatial", "episodic", "semantic", "educational", "legal", "health", "ai"]
MEMORY_SYSTEMS = ["sensory", "working", "episodic", "semantic", "procedural", "implicit", "explicit", "source"]
STUDY_TYPES = ["restudy", "retrieval_practice", "spaced", "massed", "elaboration", "generation", "interleaving", "misinformation", "ai_supported"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def hautus_rate(k: float, n: float) -> float:
    return (k + 0.5) / (n + 1.0)


def compute_sdt(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (participant, condition), g in df.groupby(["participant", "condition"]):
        hits = int(((g["old_item"] == 1) & (g["response_old"] == 1)).sum())
        misses = int(((g["old_item"] == 1) & (g["response_old"] == 0)).sum())
        fas = int(((g["old_item"] == 0) & (g["response_old"] == 1)).sum())
        crs = int(((g["old_item"] == 0) & (g["response_old"] == 0)).sum())
        hit_rate = hautus_rate(hits, hits + misses)
        fa_rate = hautus_rate(fas, fas + crs)
        rows.append({
            "participant": participant,
            "condition": condition,
            "hits": hits,
            "misses": misses,
            "false_alarms": fas,
            "correct_rejections": crs,
            "hit_rate": hit_rate,
            "false_alarm_rate": fa_rate,
            "dprime": norm.ppf(hit_rate) - norm.ppf(fa_rate),
            "criterion": -0.5 * (norm.ppf(hit_rate) + norm.ppf(fa_rate)),
        })
    return pd.DataFrame(rows)


def generate_dataset(n_participants: int = 320, trials_per_participant: int = 18, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    effects: Dict[str, Dict[str, float]] = {
        "control": {"encoding": 0.0, "interference": 0.0, "retrieval": 0.0, "false_memory": 0.0},
        "deep_encoding": {"encoding": 2.5, "interference": -0.2, "retrieval": 0.0, "false_memory": -0.05},
        "shallow_encoding": {"encoding": -2.0, "interference": 0.2, "retrieval": 0.0, "false_memory": 0.04},
        "retrieval_practice": {"encoding": 0.6, "interference": -0.2, "retrieval": 0.18, "false_memory": -0.04},
        "restudy": {"encoding": 0.7, "interference": 0.0, "retrieval": 0.04, "false_memory": 0.0},
        "spaced": {"encoding": 0.8, "interference": -0.4, "retrieval": 0.12, "false_memory": -0.03},
        "massed": {"encoding": 0.5, "interference": 0.3, "retrieval": 0.02, "false_memory": 0.02},
        "misinformation": {"encoding": 0.1, "interference": 2.0, "retrieval": -0.04, "false_memory": 0.22},
        "source_monitoring": {"encoding": 0.5, "interference": 0.8, "retrieval": 0.0, "false_memory": 0.06},
        "ai_supported": {"encoding": 0.7, "interference": -0.1, "retrieval": 0.10, "false_memory": 0.02},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        memory_trait = rng.normal(0, 0.45)
        attention_trait = rng.normal(0, 0.45)
        confidence_bias = rng.normal(0, 0.08)
        speed_factor = rng.normal(0, 0.14)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            domain = rng.choice(DOMAINS)
            memory_system = rng.choice(MEMORY_SYSTEMS)
            study_type = rng.choice(STUDY_TYPES)
            if condition in ["retrieval_practice", "restudy", "spaced", "massed", "misinformation", "ai_supported"]:
                study_type = condition
            if condition == "deep_encoding":
                study_type = "elaboration"
            if condition == "shallow_encoding":
                study_type = "restudy"

            ce = effects[condition]
            item_id = f"M{trial:03d}_{participant}"
            retrieval_practice = int(condition in ["retrieval_practice", "spaced", "ai_supported"] or study_type == "retrieval_practice")
            misinformation_exposure = int(condition == "misinformation" or study_type == "misinformation")
            old_item = int(rng.random() < 0.62)

            spacing_interval = float(np.clip(rng.normal(3.0 + 4.0 * (condition == "spaced") - 2.5 * (condition == "massed"), 1.2), 0, 14))
            delay = float(rng.choice([0.25, 1, 3, 7, 14, 30], p=[0.16, 0.20, 0.20, 0.18, 0.16, 0.10]))
            encoding_depth = float(np.clip(rng.normal(5.5 + ce["encoding"] + 0.4 * attention_trait, 1.2), 0, 10))
            cue_quality = float(np.clip(rng.normal(5.3 + 0.30 * encoding_depth + 0.6 * (condition == "ai_supported"), 1.0), 0, 10))
            interference = float(np.clip(rng.normal(3.0 + ce["interference"] + 0.5 * (domain in ["legal", "episodic"]) + 0.4 * misinformation_exposure, 1.1), 0, 10))
            consolidation_support = float(np.clip(rng.normal(5.0 + 0.35 * spacing_interval + 0.3 * (condition == "spaced"), 1.2), 0, 10))
            source_context = float(np.clip(rng.normal(5.0 + 0.35 * encoding_depth - 1.2 * misinformation_exposure + 0.4 * (condition == "source_monitoring"), 1.1), 0, 10))
            forgetting_rate = float(np.clip(rng.normal(0.10 + 0.018 * interference - 0.008 * consolidation_support - 0.012 * retrieval_practice - 0.006 * spacing_interval, 0.025), 0.01, 0.35))
            initial_strength = float(np.clip(0.38 + 0.055 * encoding_depth + 0.025 * cue_quality + 0.050 * memory_trait + 0.025 * attention_trait, 0.05, 1.25))
            strength = float(np.clip(initial_strength * np.exp(-forgetting_rate * delay) + 0.16 * retrieval_practice + (0.02 * spacing_interval if condition == "spaced" else 0.0), 0, 1.8))

            retrieval_logit = -1.6 + 2.6 * strength + 0.16 * cue_quality - 0.20 * interference + 0.10 * consolidation_support + 0.16 * retrieval_practice + 0.12 * memory_trait - 0.06 * delay / 7.0 + rng.normal(0, 0.30)
            recall_accuracy = float(np.clip(logistic(np.array([retrieval_logit]))[0] + rng.normal(0, 0.04), 0, 1))
            retrieval_fluency = float(np.clip(rng.normal(2.0 + 4.5 * recall_accuracy + 0.25 * cue_quality - 0.22 * interference, 1.0), 0, 10))

            false_alarm_base = logistic(np.array([-2.0 + 0.20 * interference + 0.24 * misinformation_exposure - 0.12 * source_context + ce["false_memory"]]))[0]
            if old_item:
                response_old_prob = float(np.clip(0.30 + 0.62 * recall_accuracy + 0.04 * retrieval_fluency - 0.03 * misinformation_exposure, 0.01, 0.99))
            else:
                response_old_prob = float(np.clip(false_alarm_base + 0.06 * retrieval_fluency + 0.08 * misinformation_exposure, 0.01, 0.99))
            response_old = int(rng.random() < response_old_prob)
            correct = int((old_item == 1 and response_old == 1) or (old_item == 0 and response_old == 0))

            source_correct_prob = float(np.clip(0.22 + 0.55 * old_item * response_old + 0.05 * source_context + 0.03 * encoding_depth - 0.07 * interference - 0.18 * misinformation_exposure, 0.01, 0.98))
            source_correct = int(rng.random() < source_correct_prob)

            recognition_confidence = float(np.clip(0.35 + 0.40 * response_old_prob + 0.20 * retrieval_fluency / 10 + confidence_bias - 0.04 * delay / 14 + rng.normal(0, 0.08), 0, 1))
            response_time_ms = int(np.clip(np.exp(math.log(1200) - 0.055 * retrieval_fluency + 0.040 * interference + 0.018 * delay + 0.025 * (1 - correct) + speed_factor + rng.normal(0, 0.14)), 150, 60000))
            learning_transfer = float(np.clip(0.22 + 0.50 * recall_accuracy + 0.06 * retrieval_practice + 0.03 * encoding_depth + 0.05 * (condition == "spaced") - 0.04 * interference + rng.normal(0, 0.06), 0, 1))

            rows.append({
                "participant": participant,
                "condition": condition,
                "domain": domain,
                "trial": trial,
                "item_id": item_id,
                "memory_system": memory_system,
                "study_type": study_type,
                "encoding_depth": round(encoding_depth, 3),
                "retrieval_practice": retrieval_practice,
                "spacing_interval": round(spacing_interval, 3),
                "delay": round(delay, 3),
                "retention_strength": round(strength, 4),
                "cue_quality": round(cue_quality, 3),
                "interference": round(interference, 3),
                "consolidation_support": round(consolidation_support, 3),
                "source_context": round(source_context, 3),
                "misinformation_exposure": misinformation_exposure,
                "old_item": old_item,
                "response_old": response_old,
                "source_correct": source_correct,
                "correct": correct,
                "recall_accuracy": round(recall_accuracy, 4),
                "recognition_confidence": round(recognition_confidence, 4),
                "retrieval_fluency": round(retrieval_fluency, 3),
                "response_time_ms": response_time_ms,
                "learning_transfer": round(learning_transfer, 4),
                "forgetting_rate": round(forgetting_rate, 4),
            })

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    df.groupby("condition").agg(
        n_trials=("correct", "size"),
        participants=("participant", "nunique"),
        correct_rate=("correct", "mean"),
        mean_recall_accuracy=("recall_accuracy", "mean"),
        old_response_rate=("response_old", "mean"),
        source_correct_rate=("source_correct", "mean"),
        mean_confidence=("recognition_confidence", "mean"),
        mean_fluency=("retrieval_fluency", "mean"),
        mean_response_time_ms=("response_time_ms", "mean"),
        mean_transfer=("learning_transfer", "mean"),
        mean_retention_strength=("retention_strength", "mean"),
        mean_forgetting_rate=("forgetting_rate", "mean"),
    ).reset_index().to_csv(outputs / "summary_by_condition.csv", index=False)

    df.groupby(["condition", "delay"]).agg(
        n_trials=("correct", "size"),
        correct_rate=("correct", "mean"),
        mean_recall_accuracy=("recall_accuracy", "mean"),
        mean_retention_strength=("retention_strength", "mean"),
        mean_response_time_ms=("response_time_ms", "mean"),
    ).reset_index().to_csv(outputs / "summary_by_delay.csv", index=False)

    compute_sdt(df).to_csv(outputs / "signal_detection_by_participant_condition.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)
    if not STATSMODELS_AVAILABLE:
        (outputs / "model_summary.txt").write_text("statsmodels unavailable. Install requirements.txt.\n", encoding="utf-8")
        return

    model_text = []
    formulas = {
        "correct_memory": ("correct ~ condition + domain + memory_system + study_type + encoding_depth + retrieval_practice + spacing_interval + delay + retention_strength + cue_quality + interference + consolidation_support + source_context + misinformation_exposure", sm.families.Binomial()),
        "old_response": ("response_old ~ condition + old_item + retention_strength + cue_quality + interference + retrieval_fluency + misinformation_exposure + recognition_confidence", sm.families.Binomial()),
    }
    for name, (formula, family) in formulas.items():
        result = smf.glm(formula, data=df, family=family).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
        model_text.append(f"\n\n=== {name} model ===\n{result.summary()}")
        pd.DataFrame({"term": result.params.index, "coef": result.params.values, "se": result.bse.values}).to_csv(outputs / f"{name}_coefficients.csv", index=False)

    for name, formula in {
        "recall_accuracy": "recall_accuracy ~ condition + study_type + encoding_depth + retrieval_practice + spacing_interval + delay + retention_strength + cue_quality + interference + consolidation_support + misinformation_exposure",
        "response_time": "np.log(response_time_ms) ~ condition + delay + retrieval_practice + retention_strength + cue_quality + interference + retrieval_fluency + correct + recognition_confidence",
        "learning_transfer": "learning_transfer ~ condition + study_type + encoding_depth + retrieval_practice + spacing_interval + delay + recall_accuracy + retention_strength + interference",
    }.items():
        env = {"np": np}
        result = smf.ols(formula, data=df, eval_env=1).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
        model_text.append(f"\n\n=== {name} model ===\n{result.summary()}")
        pd.DataFrame({"term": result.params.index, "coef": result.params.values, "se": result.bse.values}).to_csv(outputs / f"{name}_coefficients.csv", index=False)

    (outputs / "model_summary.txt").write_text("\n".join(model_text), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true")
    parser.add_argument("--input", type=Path)
    parser.add_argument("--output", type=Path, default=Path("data/memory_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=320)
    parser.add_argument("--trials", type=int, default=18)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = generate_dataset(args.participants, args.trials, args.seed)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default_input = Path("data/memory_trials.csv")
        if default_input.exists():
            df = pd.read_csv(default_input)
        else:
            df = generate_dataset(seed=args.seed)
            default_input.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(default_input, index=False)
            print(f"No input provided. Generated default dataset: {default_input}")

    summarize_data(df, args.outputs)
    run_models(df, args.outputs)
    print(f"Wrote outputs to: {args.outputs}")


if __name__ == "__main__":
    main()
