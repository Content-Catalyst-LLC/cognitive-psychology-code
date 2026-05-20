# Cognitive Constraints in Organizational Decision Making

This folder contains reproducible research code for studying cognitive constraints in organizational decision making. The examples are designed for cognitive psychologists, organizational researchers, behavioral scientists, decision scientists, and applied research teams studying bounded rationality, information overload, attention, satisficing, working-memory limits, institutional pressure, and decision-support systems.

## Research focus

The code operationalizes organizational decision load as a combined burden of:

- information load
- uncertainty load
- coordination load
- institutional pressure
- feedback delay
- automation reliance
- psychological safety
- dissent availability

The repository supports simulation, statistical modeling, validation, signal-detection analysis, accumulator-style decision modeling, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, mixed modeling, logistic modeling, and output summaries
- `r/` — hierarchical modeling and tidyverse workflow for decision-quality and satisficing analysis
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — simulation of bounded organizational choice under cognitive burden
- `c/` — lightweight Monte Carlo burden-threshold simulator
- `cpp/` — drift-diffusion / evidence-accumulation style decision simulation
- `fortran/` — signal-detection model for risk recognition under cognitive load
- `go/` — CSV validation utility for research datasets
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
python3 python/cognitive_constraints_model.py --simulate --output data/organizational_decision_trials.csv --outputs outputs
python3 python/cognitive_constraints_model.py --input data/organizational_decision_trials.csv --outputs outputs
Rscript r/cognitive_constraints_analysis.R data/organizational_decision_trials.csv outputs
go run go/validator.go data/organizational_decision_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/organizational_decision_trials.csv
```
