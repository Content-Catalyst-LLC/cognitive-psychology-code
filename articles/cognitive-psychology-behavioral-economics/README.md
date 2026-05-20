# Cognitive Psychology and Behavioral Economics

This folder contains reproducible research code for studying the relationship between cognitive psychology and behavioral economics. The examples are designed for cognitive psychologists, behavioral economists, decision scientists, policy researchers, experimental economists, public-policy analysts, organizational researchers, and research teams studying bounded rationality, heuristics, framing, loss aversion, intertemporal choice, defaults, risk perception, choice architecture, and real-world decision behavior.

## Research focus

The code operationalizes behavioral-economic decision processes through:

- bounded rationality
- cognitive load
- attention limits
- working-memory burden
- framing condition
- reference point
- gain/loss domain
- loss aversion
- default acceptance
- risk preference
- delay discounting
- social influence
- nudge exposure
- policy-relevant choice outcomes

The repository supports simulation, statistical modeling, validation, prospect-theory value functions, discounting models, logistic choice models, experimental summaries, policy-effect estimates, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, behavioral-choice modeling, prospect-theory utilities, and summaries
- `r/` — hierarchical modeling and tidyverse workflow for behavioral-economics experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — prospect-theory and intertemporal-choice simulation
- `c` — fast utility/value and loss-aversion simulation
- `cpp` — choice-architecture simulation with defaults and framing
- `fortran` — signal-detection-style risk-perception model
- `go` — CSV validation utility for behavioral-economics datasets
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated model outputs and summaries

## Suggested workflow

1. Generate or inspect the sample dataset.
2. Validate the data structure.
3. Run Python or R models.
4. Use SQL views for transparent analytical summaries.
5. Use C/C++/Fortran/Julia examples for computational simulations.
6. Save generated summaries to `outputs/`.

## Example commands

From this article folder:

```bash
python3 python/behavioral_economics_model.py --simulate --output data/behavioral_economics_trials.csv --outputs outputs
python3 python/behavioral_economics_model.py --input data/behavioral_economics_trials.csv --outputs outputs
Rscript r/behavioral_economics_analysis.R data/behavioral_economics_trials.csv outputs
go run go/validator.go data/behavioral_economics_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/behavioral_economics_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognitive-psychology-behavioral-economics
