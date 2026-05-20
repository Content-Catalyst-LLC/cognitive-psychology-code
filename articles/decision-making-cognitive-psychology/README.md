# Decision Making in Cognitive Psychology

This folder contains reproducible research code for studying decision making in cognitive psychology, judgment and decision making, behavioral economics, risk perception, naturalistic decision making, human factors, and human-AI interaction. The examples are designed for researchers studying expected value, expected utility, prospect theory, loss aversion, probability weighting, evidence accumulation, drift-diffusion-style variables, risky choice, response time, confidence, affect, cognitive load, uncertainty, decision quality, regret, feedback, and decision-support systems.

## Research focus

The code operationalizes decision making through:

- decision condition
- decision domain
- option count
- probability
- payoff
- expected value
- expected utility
- subjective value
- reference point
- gain/loss frame
- loss-aversion parameter
- probability weighting
- evidence strength
- drift-rate proxy
- decision threshold
- response time
- risky choice
- optimal choice
- decision accuracy
- confidence
- affective valence
- cognitive load
- time pressure
- uncertainty
- feedback
- regret
- decision quality
- AI assistance and verification burden

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, decision models, prospect-theory features, evidence accumulation, and plots
- `r/` — hierarchical modeling workflow for decision-making experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — drift-diffusion and naturalistic decision simulation
- `c` — fast expected-utility and satisficing simulator
- `cpp` — evidence-accumulation simulator
- `fortran` — threshold and response-time model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/decision_model.py --simulate --output data/decision_trials.csv --outputs outputs
python3 python/decision_model.py --input data/decision_trials.csv --outputs outputs
Rscript r/decision_analysis.R data/decision_trials.csv outputs
go run go/validator.go data/decision_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/decision_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/decision-making-cognitive-psychology
