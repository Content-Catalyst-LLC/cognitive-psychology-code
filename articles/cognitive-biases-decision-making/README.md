# Cognitive Biases in Decision Making

This folder contains reproducible research code for studying cognitive biases in decision making, judgment under uncertainty, behavioral economics, risk perception, institutional decision systems, and human-AI interaction. The examples are designed for researchers studying framing effects, anchoring, confirmation bias, base-rate neglect, overconfidence, calibration error, hindsight bias, loss aversion, probability weighting, availability bias, bias blind spot, debiasing interventions, group decision safeguards, and algorithmic decision-support risk.

## Research focus

The code operationalizes cognitive bias through:

- bias type
- decision frame
- gain/loss domain
- anchor value
- base rate
- representativeness
- evidence valence
- confirmation congruence
- confidence rating
- actual accuracy
- calibration error
- overconfidence
- loss-aversion parameter
- probability weighting
- risky choice
- response time
- cognitive load
- time pressure
- debiasing condition
- pre/post intervention status
- decision quality
- institutional review flag

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, bias models, prospect-theory features, and plots
- `r/` — hierarchical modeling workflow for cognitive-bias experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — prospect-theory and probability-weighting simulation
- `c` — fast framing and loss-aversion simulator
- `cpp` — confirmation-bias evidence-search simulator
- `fortran` — calibration and overconfidence model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/cognitive_bias_model.py --simulate --output data/cognitive_bias_trials.csv --outputs outputs
python3 python/cognitive_bias_model.py --input data/cognitive_bias_trials.csv --outputs outputs
Rscript r/cognitive_bias_analysis.R data/cognitive_bias_trials.csv outputs
go run go/validator.go data/cognitive_bias_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/cognitive_bias_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognitive-biases-decision-making
