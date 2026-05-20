#!/usr/bin/env python3
"""
Problem solving in cognitive psychology.

This script can:
1. Generate synthetic problem-solving trial data.
2. Estimate models for solution accuracy, solution quality, strategy switching,
   insight events, error count, and response time.
3. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
learning science, AI, human factors, education, and decision-science research.
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
    "high_load",
    "representation_support",
    "analogical_support",
    "metacognitive_prompt",
    "dynamic_uncertainty",
]

STRATEGIES = [
    "algorithmic",
    "heuristic",
    "means_end",
    "analogical",
    "insight",
    "decomposition",
    "trial_error",
]

PROBLEMS = ["PS01", "PS02", "PS03", "PS04", "PS05"]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 220,
    trials_per_participant: int = 12,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"rep": 6.0, "goal": 6.5, "wm": 5.0, "meta": 5.6, "uncertainty": 4.5},
        "high_load": {"rep": 4.7, "goal": 5.3, "wm": 8.0, "meta": 4.4, "uncertainty": 5.5},
        "representation_support": {"rep": 8.2, "goal": 8.0, "wm": 4.2, "meta": 6.8, "uncertainty": 4.2},
        "analogical_support": {"rep": 7.6, "goal": 7.2, "wm": 5.4, "meta": 6.7, "uncertainty": 4.8},
        "metacognitive_prompt": {"rep": 7.0, "goal": 7.0, "wm": 5.6, "meta": 8.2, "uncertainty": 4.8},
        "dynamic_uncertainty": {"rep": 5.6, "goal": 5.8, "wm": 7.0, "meta": 5.4, "uncertainty": 8.3},
    }

    problem_difficulty = {"PS01": 4.2, "PS02": 5.8, "PS03": 6.9, "PS04": 7.6, "PS05": 8.5}

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        general_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]
            problem_id = rng.choice(PROBLEMS)

            difficulty = np.clip(rng.normal(problem_difficulty[problem_id], 0.8), 0, 10)
            representation_quality = np.clip(rng.normal(params["rep"] + 0.35 * general_skill - 0.08 * difficulty, 0.9), 0, 10)
            goal_clarity = np.clip(rng.normal(params["goal"] + 0.25 * general_skill - 0.04 * difficulty, 0.9), 0, 10)
            constraint_load = np.clip(rng.normal(3.0 + 0.65 * difficulty + 0.25 * params["uncertainty"], 0.9), 0, 10)
            wm_load = np.clip(rng.normal(params["wm"] + 0.20 * difficulty - 0.15 * representation_quality, 0.9), 0, 10)
            metacognitive_monitoring = np.clip(rng.normal(params["meta"] + 0.20 * general_skill, 0.9), 0, 10)

            strategy_probs = np.array([0.10, 0.18, 0.22, 0.14, 0.08, 0.18, 0.10], dtype=float)

            if condition == "analogical_support":
                strategy_probs[STRATEGIES.index("analogical")] += 0.22
            if condition == "representation_support":
                strategy_probs[STRATEGIES.index("decomposition")] += 0.16
                strategy_probs[STRATEGIES.index("means_end")] += 0.06
            if condition == "metacognitive_prompt":
                strategy_probs[STRATEGIES.index("means_end")] += 0.10
                strategy_probs[STRATEGIES.index("decomposition")] += 0.10
            if condition == "high_load":
                strategy_probs[STRATEGIES.index("heuristic")] += 0.18
                strategy_probs[STRATEGIES.index("trial_error")] += 0.12
            if condition == "dynamic_uncertainty":
                strategy_probs[STRATEGIES.index("trial_error")] += 0.16
                strategy_probs[STRATEGIES.index("heuristic")] += 0.08

            strategy_probs = strategy_probs / strategy_probs.sum()
            strategy_type = rng.choice(STRATEGIES, p=strategy_probs)

            insight_logit = (
                -2.4
                + 0.42 * representation_quality
                + 0.18 * metacognitive_monitoring
                - 0.20 * wm_load
                - 0.18 * constraint_load
                + (0.85 if strategy_type == "insight" else 0.0)
                + (0.45 if strategy_type == "analogical" else 0.0)
                + rng.normal(0, 0.25)
            )
            insight_event = int(rng.random() < logistic(np.array([insight_logit]))[0])

            switch_lambda = np.exp(
                -0.85
                + 0.18 * difficulty
                + 0.16 * wm_load
                + 0.12 * constraint_load
                - 0.14 * metacognitive_monitoring
                - 0.08 * representation_quality
            )
            strategy_switch_count = int(np.clip(rng.poisson(switch_lambda), 0, 12))
            switched_strategy = int(strategy_switch_count > 0)

            strategy_bonus = {
                "algorithmic": 0.45,
                "heuristic": -0.10,
                "means_end": 0.35,
                "analogical": 0.40,
                "insight": 0.32,
                "decomposition": 0.42,
                "trial_error": -0.18,
            }[strategy_type]

            accuracy_logit = (
                -2.2
                + 0.40 * representation_quality
                + 0.22 * goal_clarity
                + 0.22 * metacognitive_monitoring
                + 0.55 * insight_event
                + strategy_bonus
                - 0.30 * difficulty
                - 0.22 * wm_load
                - 0.16 * constraint_load
                + general_skill
                + rng.normal(0, 0.30)
            )
            solution_accuracy = int(rng.random() < logistic(np.array([accuracy_logit]))[0])

            error_lambda = np.exp(
                -0.55
                + 0.15 * difficulty
                + 0.18 * wm_load
                + 0.12 * constraint_load
                - 0.15 * representation_quality
                - 0.10 * metacognitive_monitoring
                - 0.25 * solution_accuracy
            )
            error_count = int(np.clip(rng.poisson(error_lambda), 0, 30))

            solution_quality = np.clip(
                rng.normal(
                    35
                    + 4.5 * representation_quality
                    + 3.0 * goal_clarity
                    + 2.2 * metacognitive_monitoring
                    + 8.5 * solution_accuracy
                    + 4.0 * insight_event
                    - 2.1 * difficulty
                    - 1.6 * wm_load
                    - 1.3 * error_count,
                    7.5,
                ),
                0,
                100,
            )

            confidence = np.clip(
                rng.normal(
                    2.3
                    + 0.040 * solution_quality
                    + 0.42 * solution_accuracy
                    + 0.20 * metacognitive_monitoring
                    - 0.08 * error_count,
                    0.8,
                ),
                0,
                10,
            )

            log_rt = (
                math.log(3000)
                + 0.065 * difficulty
                + 0.050 * wm_load
                + 0.040 * constraint_load
                + 0.035 * strategy_switch_count
                - 0.035 * representation_quality
                - 0.020 * solution_accuracy
                + speed_factor
                + rng.normal(0, 0.14)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 120000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "problem_id": problem_id,
                    "trial": trial,
                    "problem_difficulty": round(float(difficulty), 3),
                    "representation_quality": round(float(representation_quality), 3),
                    "goal_clarity": round(float(goal_clarity), 3),
                    "constraint_load": round(float(constraint_load), 3),
                    "wm_load": round(float(wm_load), 3),
                    "strategy_type": strategy_type,
                    "metacognitive_monitoring": round(float(metacognitive_monitoring), 3),
                    "strategy_switch_count": strategy_switch_count,
                    "switched_strategy": switched_strategy,
                    "insight_event": insight_event,
                    "solution_accuracy": solution_accuracy,
                    "solution_quality": round(float(solution_quality), 3),
                    "error_count": error_count,
                    "confidence": round(float(confidence), 3),
                    "response_time_ms": response_time_ms,
                }
            )

    return pd.DataFrame(rows)


def summarize_data(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    by_condition = (
        df.groupby("condition")
        .agg(
            n_trials=("solution_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_difficulty=("problem_difficulty", "mean"),
            mean_representation=("representation_quality", "mean"),
            mean_goal_clarity=("goal_clarity", "mean"),
            mean_constraint_load=("constraint_load", "mean"),
            mean_wm_load=("wm_load", "mean"),
            mean_metacognition=("metacognitive_monitoring", "mean"),
            switch_rate=("switched_strategy", "mean"),
            mean_switch_count=("strategy_switch_count", "mean"),
            insight_rate=("insight_event", "mean"),
            accuracy_rate=("solution_accuracy", "mean"),
            mean_solution_quality=("solution_quality", "mean"),
            mean_errors=("error_count", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_strategy = (
        df.groupby("strategy_type")
        .agg(
            n_trials=("solution_accuracy", "size"),
            accuracy_rate=("solution_accuracy", "mean"),
            mean_solution_quality=("solution_quality", "mean"),
            insight_rate=("insight_event", "mean"),
            mean_errors=("error_count", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_strategy.to_csv(outputs / "summary_by_strategy.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    accuracy_formula = (
        "solution_accuracy ~ condition + strategy_type + problem_difficulty + "
        "representation_quality + goal_clarity + constraint_load + wm_load + "
        "metacognitive_monitoring + switched_strategy + insight_event"
    )

    accuracy_model = smf.glm(
        accuracy_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Solution-accuracy model: logistic GLM ===\n")
    model_text.append(str(accuracy_model.summary()))

    switch_formula = (
        "switched_strategy ~ condition + problem_difficulty + representation_quality + "
        "constraint_load + wm_load + metacognitive_monitoring"
    )

    switch_model = smf.glm(
        switch_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Strategy-switch model: logistic GLM ===\n")
    model_text.append(str(switch_model.summary()))

    quality_formula = (
        "solution_quality ~ condition + strategy_type + problem_difficulty + "
        "representation_quality + goal_clarity + constraint_load + wm_load + "
        "metacognitive_monitoring + insight_event + solution_accuracy + error_count"
    )

    quality_model = smf.ols(quality_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Solution-quality model: cluster-robust OLS ===\n")
    model_text.append(str(quality_model.summary()))

    error_formula = (
        "error_count ~ condition + strategy_type + problem_difficulty + "
        "representation_quality + constraint_load + wm_load + metacognitive_monitoring"
    )

    error_model = smf.glm(
        error_formula,
        data=df,
        family=sm.families.Poisson(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Error-count model: Poisson GLM ===\n")
    model_text.append(str(error_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ condition + strategy_type + problem_difficulty + "
        "representation_quality + constraint_load + wm_load + strategy_switch_count + solution_accuracy"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Response-time model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(model_text))

    coefficients = pd.DataFrame(
        {
            "term": accuracy_model.params.index,
            "accuracy_coef": accuracy_model.params.values,
            "accuracy_se": accuracy_model.bse.values,
        }
    )
    coefficients.to_csv(outputs / "accuracy_model_coefficients.csv", index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--simulate", action="store_true", help="Generate synthetic data.")
    parser.add_argument("--input", type=Path, help="Input CSV for modeling.")
    parser.add_argument("--output", type=Path, default=Path("data/problem_solving_trials.csv"))
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
        default_input = Path("data/problem_solving_trials.csv")
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
