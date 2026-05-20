#!/usr/bin/env python3
from __future__ import annotations

import argparse
import math
from pathlib import Path
import numpy as np
import pandas as pd

try:
    import statsmodels.formula.api as smf
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False

LEVELS = ["novice", "intermediate", "advanced", "expert"]
CONDITIONS = ["control", "deliberate_practice", "high_feedback", "low_feedback", "transfer_task", "adaptive_training", "time_pressure"]
DOMAINS = ["medicine", "engineering", "music", "sports", "programming", "decision_making"]

def logistic(x):
    return 1 / (1 + np.exp(-np.clip(x, -40, 40)))

def simulate(n_participants=240, sessions=8, seed=42):
    rng = np.random.default_rng(seed)
    rows = []
    level_map = {
        "novice": (-0.8, 5, 2.5, 2.8, 3.2),
        "intermediate": (0.0, 60, 5.8, 6.0, 6.2),
        "advanced": (0.65, 300, 8.0, 8.2, 8.0),
        "expert": (1.25, 2500, 9.0, 9.0, 8.8),
    }
    cond_map = {
        "control": (5.2, 5.0, 5.4, 0),
        "deliberate_practice": (8.4, 7.2, 6.8, 0),
        "high_feedback": (6.4, 8.6, 6.4, 0),
        "low_feedback": (5.4, 3.2, 5.2, 0),
        "transfer_task": (6.8, 6.6, 7.0, 0),
        "adaptive_training": (8.0, 7.8, 8.4, 0),
        "time_pressure": (6.4, 6.0, 6.0, 1),
    }
    for p in range(1, n_participants + 1):
        participant = f"P{p:03d}"
        level = rng.choice(LEVELS, p=[0.30, 0.35, 0.23, 0.12])
        domain = rng.choice(DOMAINS)
        ability, base_hours, base_chunk, base_pattern, base_strategy = level_map[level]
        latent = rng.normal(ability, 0.35)
        speed = rng.normal(0, 0.13)
        for session in range(1, sessions + 1):
            condition = rng.choice(CONDITIONS)
            practice_base, feedback_base, adapt_base, pressure = cond_map[condition]
            difficulty = np.clip(rng.normal(5.5 + 0.45 * session + 0.6 * (condition == "transfer_task") + 0.7 * pressure, 0.9), 0, 10)
            practice_hours = np.clip(rng.normal(base_hours + session * (2.5 + 2.0 * max(latent, -0.5)), base_hours * 0.08 + 3), 0, None)
            deliberate = np.clip(rng.normal(practice_base + 0.3 * latent, 0.9), 0, 10)
            feedback = np.clip(rng.normal(feedback_base, 0.9), 0, 10)
            chunking = np.clip(rng.normal(base_chunk + 0.22 * session + 0.10 * deliberate, 0.8), 0, 10)
            pattern = np.clip(rng.normal(base_pattern + 0.20 * session + 0.10 * np.log1p(practice_hours), 0.8), 0, 10)
            strategy = np.clip(rng.normal(base_strategy + 0.18 * feedback + 0.20 * adapt_base, 0.8), 0, 10)
            load = np.clip(rng.normal(8.0 - 0.25 * chunking + 0.20 * difficulty + 0.6 * pressure, 0.9), 0, 10)
            wm = np.clip(rng.normal(7.6 - 0.28 * chunking - 0.22 * pattern + 0.25 * difficulty + 0.5 * pressure, 0.9), 0, 10)
            acc_p = logistic(-0.5 + 0.20*session + 0.20*deliberate + 0.15*feedback + 0.18*chunking + 0.18*pattern + 0.18*strategy - 0.25*difficulty - 0.14*load + 0.35*latent - 0.20*pressure)
            accuracy = float(np.clip(rng.normal(acc_p, 0.07), 0, 1))
            error = float(np.clip(1 - accuracy + rng.normal(0, 0.03), 0, 1))
            transfer = float(np.clip(rng.normal(30 + 3.4*strategy + 3.0*pattern + 2.5*chunking + 2.4*adapt_base + 12*accuracy - 1.8*difficulty, 6.0), 0, 100))
            adaptive = float(np.clip(rng.normal(2.0 + 0.32*strategy + 0.28*adapt_base + 0.12*feedback - 0.12*load, 0.8), 0, 10))
            rt = int(np.clip(np.exp(math.log(3000) - 0.11*session - 0.055*chunking - 0.060*pattern - 0.050*accuracy + 0.050*difficulty + 0.055*load - 0.08*latent - 0.16*pressure + speed + rng.normal(0,0.11)), 150, 120000))
            automaticity = float(np.clip(rng.normal(1.5 + 3.5*accuracy + 0.35*chunking + 0.32*pattern - 0.22*load - 0.18*wm, 0.8), 0, 10))
            retention = float(np.clip(rng.normal(25 + 35*accuracy + 2.5*deliberate + 2.0*feedback + 2.2*chunking - 1.4*load, 6.5), 0, 100))
            rows.append({
                "participant": participant, "expertise_level": level, "condition": condition, "domain": domain, "session": session,
                "task_id": f"SA{session:03d}_{participant}", "practice_hours": round(float(practice_hours), 3),
                "deliberate_practice_quality": round(float(deliberate), 3), "feedback_quality": round(float(feedback), 3),
                "task_difficulty": round(float(difficulty), 3), "cognitive_load": round(float(load), 3),
                "working_memory_demand": round(float(wm), 3), "chunking_score": round(float(chunking), 3),
                "pattern_recognition_score": round(float(pattern), 3), "strategy_quality": round(float(strategy), 3),
                "transfer_score": round(float(transfer), 3), "adaptive_flexibility": round(float(adaptive), 3),
                "accuracy": round(float(accuracy), 3), "error_rate": round(float(error), 3), "response_time_ms": rt,
                "automaticity_score": round(float(automaticity), 3), "retention_score": round(float(retention), 3),
            })
    return pd.DataFrame(rows)

def summarize(df, outputs):
    outputs.mkdir(parents=True, exist_ok=True)
    df.groupby("condition").agg(
        n_trials=("accuracy", "size"),
        participants=("participant", "nunique"),
        mean_accuracy=("accuracy", "mean"),
        mean_error_rate=("error_rate", "mean"),
        mean_response_time_ms=("response_time_ms", "mean"),
        mean_transfer=("transfer_score", "mean"),
        mean_automaticity=("automaticity_score", "mean"),
        mean_retention=("retention_score", "mean"),
    ).reset_index().to_csv(outputs / "summary_by_condition.csv", index=False)

    df.groupby("expertise_level").agg(
        n_trials=("accuracy", "size"),
        participants=("participant", "nunique"),
        mean_accuracy=("accuracy", "mean"),
        mean_error_rate=("error_rate", "mean"),
        mean_response_time_ms=("response_time_ms", "mean"),
        mean_transfer=("transfer_score", "mean"),
        mean_automaticity=("automaticity_score", "mean"),
    ).reset_index().to_csv(outputs / "summary_by_expertise.csv", index=False)

    df.groupby(["expertise_level", "session"]).agg(
        mean_accuracy=("accuracy", "mean"),
        mean_error_rate=("error_rate", "mean"),
        mean_response_time_ms=("response_time_ms", "mean"),
        mean_automaticity=("automaticity_score", "mean"),
    ).reset_index().to_csv(outputs / "learning_curve_by_session.csv", index=False)

def run_models(df, outputs):
    if not STATSMODELS_AVAILABLE:
        (outputs / "model_summary.txt").write_text("statsmodels unavailable. Install python/requirements.txt.\n")
        return
    summaries = []
    for name, formula in {
        "accuracy_growth": "accuracy ~ session * expertise_level + condition + domain + deliberate_practice_quality + feedback_quality + task_difficulty + chunking_score + pattern_recognition_score + strategy_quality + cognitive_load",
        "error_reduction": "error_rate ~ session * expertise_level + condition + domain + deliberate_practice_quality + feedback_quality + task_difficulty + cognitive_load",
        "transfer": "transfer_score ~ session + expertise_level + condition + domain + deliberate_practice_quality + feedback_quality + strategy_quality + pattern_recognition_score + adaptive_flexibility + accuracy",
        "automaticity": "automaticity_score ~ session + expertise_level + condition + accuracy + chunking_score + pattern_recognition_score + cognitive_load + working_memory_demand",
        "retention": "retention_score ~ session + expertise_level + condition + deliberate_practice_quality + feedback_quality + chunking_score + accuracy + cognitive_load",
    }.items():
        res = smf.ols(formula, data=df).fit(cov_type="cluster", cov_kwds={"groups": df["participant"]})
        summaries.append(f"\n\n=== {name} ===\n{res.summary()}")
        if name == "accuracy_growth":
            pd.DataFrame({"term": res.params.index, "coef": res.params.values, "se": res.bse.values}).to_csv(outputs / "accuracy_model_coefficients.csv", index=False)

    rt_df = df[df.response_time_ms >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])
    rt = smf.ols("log_response_time ~ session * expertise_level + condition + domain + accuracy + task_difficulty + cognitive_load + working_memory_demand + chunking_score + pattern_recognition_score", data=rt_df).fit(cov_type="cluster", cov_kwds={"groups": rt_df["participant"]})
    summaries.append(f"\n\n=== response_time ===\n{rt.summary()}")
    (outputs / "model_summary.txt").write_text("\n".join(summaries), encoding="utf-8")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true")
    parser.add_argument("--input", type=Path)
    parser.add_argument("--output", type=Path, default=Path("data/skill_acquisition_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=240)
    parser.add_argument("--sessions", type=int, default=8)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.simulate:
        df = simulate(args.participants, args.sessions, args.seed)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(args.output, index=False)
        print(f"Wrote simulated dataset: {args.output}")
    elif args.input:
        df = pd.read_csv(args.input)
    else:
        default = Path("data/skill_acquisition_trials.csv")
        if default.exists():
            df = pd.read_csv(default)
        else:
            df = simulate(seed=args.seed)
            default.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(default, index=False)

    summarize(df, args.outputs)
    run_models(df, args.outputs)
    print(f"Wrote outputs to: {args.outputs}")

if __name__ == "__main__":
    main()
