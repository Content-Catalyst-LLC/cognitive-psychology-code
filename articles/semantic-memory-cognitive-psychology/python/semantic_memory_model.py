#!/usr/bin/env python3
"""
Semantic memory in cognitive psychology.

This script can:
1. Generate synthetic semantic-memory trial data.
2. Estimate models for semantic verification accuracy, response time,
   category strength, false association, and confidence.
3. Build a small semantic network and run spreading-activation examples.
4. Save researcher-readable summaries to outputs/.

The simulated dataset is a reproducible scaffold for cognitive psychology,
memory research, psycholinguistics, cognitive neuroscience, AI, and knowledge
engineering.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd

try:
    import statsmodels.formula.api as smf
    import statsmodels.api as sm
    STATSMODELS_AVAILABLE = True
except Exception:
    STATSMODELS_AVAILABLE = False

try:
    import networkx as nx
    NETWORKX_AVAILABLE = True
except Exception:
    NETWORKX_AVAILABLE = False


CONDITIONS = [
    "control",
    "semantic_prime",
    "high_distance",
    "low_typicality",
    "schema_consistent",
    "schema_violation",
]

RELATIONS = ["taxonomic", "thematic", "functional", "associative", "false_related", "unrelated"]

CONCEPTS: List[Tuple[str, str]] = [
    ("bird", "animals"),
    ("robin", "animals"),
    ("ostrich", "animals"),
    ("dog", "animals"),
    ("shark", "animals"),
    ("tool", "tools"),
    ("hammer", "tools"),
    ("spoon", "tools"),
    ("wrench", "tools"),
    ("kitchen", "tools"),
    ("doctor", "professions"),
    ("nurse", "professions"),
    ("scalpel", "professions"),
    ("justice", "abstract"),
    ("law", "abstract"),
    ("democracy", "abstract"),
    ("triangle", "abstract"),
]


def logistic(x: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-np.clip(x, -40, 40)))


def generate_dataset(
    n_participants: int = 220,
    trials_per_participant: int = 14,
    seed: int = 42,
) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []

    condition_effects: Dict[str, Dict[str, float]] = {
        "control": {"distance": 3.2, "typicality": 7.2, "feature": 6.2, "assoc": 5.8, "schema": 6.8, "false": 0},
        "semantic_prime": {"distance": 2.0, "typicality": 7.6, "feature": 6.8, "assoc": 8.2, "schema": 7.4, "false": 0},
        "high_distance": {"distance": 8.4, "typicality": 2.6, "feature": 1.8, "assoc": 1.7, "schema": 2.4, "false": 0},
        "low_typicality": {"distance": 4.4, "typicality": 3.8, "feature": 4.6, "assoc": 4.2, "schema": 5.6, "false": 0},
        "schema_consistent": {"distance": 2.4, "typicality": 7.8, "feature": 6.6, "assoc": 7.2, "schema": 8.5, "false": 0},
        "schema_violation": {"distance": 5.8, "typicality": 3.2, "feature": 2.8, "assoc": 4.0, "schema": 2.4, "false": 1},
    }

    for participant_idx in range(1, n_participants + 1):
        participant = f"P{participant_idx:03d}"
        semantic_skill = rng.normal(0, 0.55)
        speed_factor = rng.normal(0, 0.16)

        for trial in range(1, trials_per_participant + 1):
            condition = rng.choice(CONDITIONS)
            params = condition_effects[condition]

            cue_concept, cue_category = CONCEPTS[int(rng.integers(0, len(CONCEPTS)))]
            if condition in {"control", "semantic_prime", "schema_consistent"} and rng.random() < 0.70:
                same_category = [c for c in CONCEPTS if c[1] == cue_category and c[0] != cue_concept]
                target_concept, category = same_category[int(rng.integers(0, len(same_category)))] if same_category else CONCEPTS[int(rng.integers(0, len(CONCEPTS)))]
            else:
                target_concept, category = CONCEPTS[int(rng.integers(0, len(CONCEPTS)))]

            relation_type = rng.choice(RELATIONS)
            if condition == "high_distance":
                relation_type = "unrelated"
            elif condition == "schema_violation":
                relation_type = "false_related"
            elif condition == "semantic_prime":
                relation_type = rng.choice(["taxonomic", "thematic", "functional", "associative"], p=[0.30, 0.25, 0.20, 0.25])

            semantic_distance = np.clip(rng.normal(params["distance"] - 0.25 * semantic_skill, 0.9), 0, 10)
            category_typicality = np.clip(rng.normal(params["typicality"] + 0.15 * semantic_skill, 0.9), 0, 10)
            feature_overlap = np.clip(rng.normal(params["feature"], 0.9), 0, 10)
            associative_strength = np.clip(rng.normal(params["assoc"], 0.9), 0, 10)
            concept_familiarity = np.clip(rng.normal(7.0 + 0.25 * semantic_skill, 1.0), 0, 10)
            concreteness = np.clip(rng.normal(7.5 if category != "abstract" else 3.0, 1.1), 0, 10)
            schema_consistency = np.clip(rng.normal(params["schema"], 0.9), 0, 10)
            false_association = int(params["false"] == 1 or relation_type == "false_related")

            fact_logit = (
                -0.2
                - 0.40 * semantic_distance
                + 0.32 * category_typicality
                + 0.24 * feature_overlap
                + 0.18 * schema_consistency
                + 0.14 * associative_strength
                - 0.90 * false_association
                + 0.10 * semantic_skill
                + rng.normal(0, 0.35)
            )
            fact_true = int(rng.random() < logistic(np.array([fact_logit]))[0])
            if condition in {"high_distance", "schema_violation"} and rng.random() < 0.65:
                fact_true = 0
            if condition in {"semantic_prime", "schema_consistent", "control"} and rng.random() < 0.70:
                fact_true = 1

            accuracy_logit = (
                -0.9
                - 0.22 * semantic_distance
                + 0.24 * category_typicality
                + 0.18 * feature_overlap
                + 0.15 * concept_familiarity
                + 0.14 * schema_consistency
                + 0.20 * int(fact_true == 1)
                - 0.75 * false_association
                + 0.85 * semantic_skill
                + rng.normal(0, 0.30)
            )
            verification_accuracy = int(rng.random() < logistic(np.array([accuracy_logit]))[0])

            category_strength = np.clip(
                rng.normal(
                    1.2
                    + 0.50 * category_typicality
                    + 0.22 * feature_overlap
                    + 0.18 * schema_consistency
                    - 0.20 * semantic_distance
                    - 0.65 * false_association,
                    0.9,
                ),
                0,
                10,
            )

            confidence = np.clip(
                rng.normal(
                    2.2
                    + 0.42 * category_strength
                    + 0.65 * verification_accuracy
                    + 0.18 * concept_familiarity
                    - 0.25 * false_association,
                    0.8,
                ),
                0,
                10,
            )

            log_rt = (
                math.log(1200)
                + 0.070 * semantic_distance
                - 0.035 * category_typicality
                - 0.030 * associative_strength
                - 0.030 * concept_familiarity
                + 0.095 * false_association
                - 0.025 * verification_accuracy
                + speed_factor
                + rng.normal(0, 0.13)
            )
            response_time_ms = int(np.clip(np.exp(log_rt), 150, 60000))

            rows.append(
                {
                    "participant": participant,
                    "condition": condition,
                    "trial": trial,
                    "cue_concept": cue_concept,
                    "target_concept": target_concept,
                    "category": category,
                    "relation_type": relation_type,
                    "semantic_distance": round(float(semantic_distance), 3),
                    "category_typicality": round(float(category_typicality), 3),
                    "feature_overlap": round(float(feature_overlap), 3),
                    "associative_strength": round(float(associative_strength), 3),
                    "concept_familiarity": round(float(concept_familiarity), 3),
                    "concreteness": round(float(concreteness), 3),
                    "schema_consistency": round(float(schema_consistency), 3),
                    "fact_true": fact_true,
                    "false_association": false_association,
                    "verification_accuracy": verification_accuracy,
                    "category_strength": round(float(category_strength), 3),
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
            n_trials=("verification_accuracy", "size"),
            participants=("participant", "nunique"),
            mean_semantic_distance=("semantic_distance", "mean"),
            mean_category_typicality=("category_typicality", "mean"),
            mean_feature_overlap=("feature_overlap", "mean"),
            mean_associative_strength=("associative_strength", "mean"),
            mean_concept_familiarity=("concept_familiarity", "mean"),
            mean_schema_consistency=("schema_consistency", "mean"),
            false_association_rate=("false_association", "mean"),
            true_fact_rate=("fact_true", "mean"),
            accuracy_rate=("verification_accuracy", "mean"),
            mean_category_strength=("category_strength", "mean"),
            mean_confidence=("confidence", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_relation = (
        df.groupby("relation_type")
        .agg(
            n_trials=("verification_accuracy", "size"),
            mean_semantic_distance=("semantic_distance", "mean"),
            mean_associative_strength=("associative_strength", "mean"),
            true_fact_rate=("fact_true", "mean"),
            accuracy_rate=("verification_accuracy", "mean"),
            mean_response_time_ms=("response_time_ms", "mean"),
        )
        .reset_index()
    )

    by_condition.to_csv(outputs / "summary_by_condition.csv", index=False)
    by_relation.to_csv(outputs / "summary_by_relation_type.csv", index=False)


def build_semantic_network(outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    edges = [
        ("bird", "robin", 0.92),
        ("bird", "ostrich", 0.55),
        ("animal", "bird", 0.80),
        ("animal", "dog", 0.85),
        ("animal", "shark", 0.72),
        ("tool", "hammer", 0.90),
        ("tool", "wrench", 0.86),
        ("kitchen", "spoon", 0.82),
        ("doctor", "nurse", 0.86),
        ("doctor", "scalpel", 0.70),
        ("justice", "law", 0.84),
        ("democracy", "law", 0.62),
        ("triangle", "geometry", 0.90),
    ]

    if not NETWORKX_AVAILABLE:
        pd.DataFrame(edges, columns=["source", "target", "weight"]).to_csv(outputs / "semantic_network_edges.csv", index=False)
        return

    graph = nx.Graph()
    graph.add_weighted_edges_from(edges)

    centrality = nx.degree_centrality(graph)
    clustering = nx.clustering(graph, weight="weight")

    rows = []
    for node in sorted(graph.nodes()):
        rows.append(
            {
                "concept": node,
                "degree": graph.degree(node),
                "degree_centrality": centrality[node],
                "weighted_clustering": clustering[node],
            }
        )

    pd.DataFrame(edges, columns=["source", "target", "weight"]).to_csv(outputs / "semantic_network_edges.csv", index=False)
    pd.DataFrame(rows).to_csv(outputs / "semantic_network_node_metrics.csv", index=False)


def run_models(df: pd.DataFrame, outputs: Path) -> None:
    outputs.mkdir(parents=True, exist_ok=True)

    if not STATSMODELS_AVAILABLE:
        with open(outputs / "model_summary.txt", "w", encoding="utf-8") as f:
            f.write("statsmodels is not available. Install requirements.txt to run models.\n")
        return

    model_text = []

    accuracy_formula = (
        "verification_accuracy ~ condition + relation_type + semantic_distance + "
        "fact_true + category_typicality + feature_overlap + associative_strength + "
        "concept_familiarity + schema_consistency + false_association"
    )

    accuracy_model = smf.glm(
        accuracy_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Semantic verification accuracy: logistic GLM ===\n")
    model_text.append(str(accuracy_model.summary()))

    rt_df = df[df["response_time_ms"] >= 150].copy()
    rt_df["log_response_time"] = np.log(rt_df["response_time_ms"])

    rt_formula = (
        "log_response_time ~ condition + relation_type + semantic_distance + fact_true + "
        "category_typicality + associative_strength + concept_familiarity + "
        "false_association + verification_accuracy"
    )

    rt_model = smf.ols(rt_formula, data=rt_df).fit(
        cov_type="cluster",
        cov_kwds={"groups": rt_df["participant"]},
    )
    model_text.append("\n\n=== Retrieval latency model: log response time ===\n")
    model_text.append(str(rt_model.summary()))

    category_formula = (
        "category_strength ~ condition + semantic_distance + category_typicality + "
        "feature_overlap + associative_strength + schema_consistency + false_association"
    )

    category_model = smf.ols(category_formula, data=df).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== Category strength model ===\n")
    model_text.append(str(category_model.summary()))

    false_assoc_formula = (
        "false_association ~ condition + semantic_distance + category_typicality + "
        "feature_overlap + associative_strength + schema_consistency"
    )

    false_assoc_model = smf.glm(
        false_assoc_formula,
        data=df,
        family=sm.families.Binomial(),
    ).fit(
        cov_type="cluster",
        cov_kwds={"groups": df["participant"]},
    )
    model_text.append("\n\n=== False semantic association model ===\n")
    model_text.append(str(false_assoc_model.summary()))

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
    parser.add_argument("--output", type=Path, default=Path("data/semantic_memory_trials.csv"))
    parser.add_argument("--outputs", type=Path, default=Path("outputs"))
    parser.add_argument("--participants", type=int, default=220)
    parser.add_argument("--trials", type=int, default=14)
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
        default_input = Path("data/semantic_memory_trials.csv")
        if default_input.exists():
            df = pd.read_csv(default_input)
        else:
            df = generate_dataset(seed=args.seed)
            default_input.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(default_input, index=False)
            print(f"No input provided. Generated default dataset: {default_input}")

    summarize_data(df, args.outputs)
    build_semantic_network(args.outputs)
    run_models(df, args.outputs)
    print(f"Wrote summaries, semantic network, and model outputs to: {args.outputs}")


if __name__ == "__main__":
    main()
