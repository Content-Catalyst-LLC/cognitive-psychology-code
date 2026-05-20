# Risk Perception and Uncertainty

This folder contains reproducible research code for studying risk perception and uncertainty in cognitive psychology. The examples are designed for cognitive psychologists, behavioral economists, risk researchers, public-health communicators, environmental-risk analysts, policy researchers, human factors researchers, AI governance researchers, and computational social scientists studying perceived risk, subjective probability, framing, affect, loss aversion, probability weighting, trust, ambiguity, safe choice, protective action, and response time.

## Research focus

The code operationalizes risk perception through:

- subjective probability
- objective probability
- consequence severity
- affective intensity
- perceived controllability
- familiarity
- dread
- trust in institution
- ambiguity
- frame
- probability weighting
- loss aversion
- perceived risk
- risk-benefit judgment
- safe choice
- protective action
- uncertainty tolerance
- response time
- confidence
- risk communication clarity

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, perceived-risk models, choice models, and plots
- `r/` — hierarchical modeling workflow for risk-perception experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — prospect-theory and probability-weighting simulation
- `c` — fast risk-weighting simulator
- `cpp` — social amplification and risk-communication simulation
- `fortran` — signal-detection-style risk sensitivity model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/risk_perception_model.py --simulate --output data/risk_perception_trials.csv --outputs outputs
python3 python/risk_perception_model.py --input data/risk_perception_trials.csv --outputs outputs
Rscript r/risk_perception_analysis.R data/risk_perception_trials.csv outputs
go run go/validator.go data/risk_perception_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/risk_perception_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/risk-perception-uncertainty
