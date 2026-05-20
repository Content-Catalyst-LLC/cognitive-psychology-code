# Cognitive Systems in Artificial Intelligence

This folder contains reproducible research code for studying cognitive systems in artificial intelligence from a cognitive-psychology perspective. The examples are designed for cognitive psychologists, AI researchers, human-computer interaction researchers, decision scientists, computational modelers, and research teams studying perception, memory, representation, learning, reasoning, decision making, uncertainty, explainability, and human-AI interaction.

## Research focus

The code operationalizes cognitive-system performance through:

- representation quality
- retrieval latency
- working-memory load
- uncertainty level
- policy entropy
- prediction accuracy
- action success
- explanation quality
- response latency
- calibration error
- human trust and override behavior

The repository supports simulation, statistical modeling, validation, signal-detection analysis, policy-selection modeling, memory-retrieval modeling, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, cognitive-systems modeling, calibration analysis, and summaries
- `r/` — hierarchical modeling and tidyverse workflow for architecture comparison
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — belief-state and policy-selection simulation
- `c/` — fast memory-retrieval and capacity simulation
- `cpp/` — production-system / evidence-accumulation style architecture simulation
- `fortran/` — signal-detection and calibration model for AI-assisted cognition
- `go/` — CSV validation utility for cognitive-systems datasets
- `rust/` — fast summary and data-quality utility
- `notebooks/` — notebook workflow scaffold
- `docs/` — methodological protocol and measurement notes
- `outputs/` — generated model outputs and summaries

## Suggested workflow

1. Generate or inspect the sample dataset.
2. Validate the data structure.
3. Run Python or R models.
4. Use SQL views for transparent analytical summaries.
5. Use the C/C++/Fortran/Julia examples for computational simulations.
6. Save generated summaries to `outputs/`.

## Example commands

From this article folder:

```bash
python3 python/cognitive_systems_ai_model.py --simulate --output data/cognitive_systems_trials.csv --outputs outputs
python3 python/cognitive_systems_ai_model.py --input data/cognitive_systems_trials.csv --outputs outputs
Rscript r/cognitive_systems_ai_analysis.R data/cognitive_systems_trials.csv outputs
go run go/validator.go data/cognitive_systems_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/cognitive_systems_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognitive-systems-artificial-intelligence
