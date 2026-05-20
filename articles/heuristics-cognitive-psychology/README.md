# Heuristics in Cognitive Psychology

This folder contains reproducible research code for studying heuristics in cognitive psychology, judgment and decision making, behavioral economics, risk perception, human factors, and human-AI interaction. The examples are designed for researchers studying anchoring, availability, representativeness, recognition, fluency, affect, effort reduction, bounded rationality, fast-and-frugal heuristics, strategy selection, decision accuracy, response time, confidence, calibration, ecological rationality, and bias risk.

## Research focus

The code operationalizes heuristic judgment through:

- heuristic type
- anchor value
- adjustment
- recall ease
- representativeness
- base-rate use
- recognition strength
- processing fluency
- affective valence
- cue validity
- cue count
- information cost
- time pressure
- cognitive load
- strategy complexity
- subjective effort
- judged probability
- choice outcome
- correct choice
- confidence
- calibration error
- response time
- adaptive fit
- bias magnitude

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, heuristic models, strategy-comparison models, and plots
- `r/` — hierarchical modeling workflow for heuristic-judgment experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — fast-and-frugal heuristic simulation
- `c` — fast anchoring and adjustment simulator
- `cpp` — adaptive strategy-selection simulator
- `fortran` — effort-accuracy tradeoff model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/heuristics_model.py --simulate --output data/heuristics_trials.csv --outputs outputs
python3 python/heuristics_model.py --input data/heuristics_trials.csv --outputs outputs
Rscript r/heuristics_analysis.R data/heuristics_trials.csv outputs
go run go/validator.go data/heuristics_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/heuristics_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/heuristics-cognitive-psychology
