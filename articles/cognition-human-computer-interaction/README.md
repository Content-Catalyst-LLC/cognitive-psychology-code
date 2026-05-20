# Cognition in Human-Computer Interaction

This folder contains reproducible research code for studying cognition in human-computer interaction. The examples are designed for cognitive psychologists, HCI researchers, human factors specialists, usability researchers, accessibility researchers, UX researchers, AI-interface researchers, and research teams studying perception, attention, working memory, mental models, task success, cognitive load, decision latency, errors, trust, and adaptive interfaces.

## Research focus

The code operationalizes cognitive HCI through:

- perceptual load
- attentional demand
- working-memory load
- task difficulty
- mental-model alignment
- interface condition
- task success
- response time
- error count
- trust calibration
- automation reliance
- accessibility friction

The repository supports simulation, statistical modeling, validation, Fitts-style interaction modeling, signal-detection analysis, usability summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, usability modeling, latency models, and summaries
- `r/` — hierarchical modeling and tidyverse workflow for interface comparison
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — cognitive-load and task-success simulation
- `c/` — fast reaction-time / interaction-cost simulator
- `cpp/` — Fitts-style pointing and decision-cost simulation
- `fortran/` — signal-detection model for interface warning recognition
- `go/` — CSV validation utility for HCI datasets
- `rust/` — fast summary and data-quality utility
- `notebooks/` — notebook workflow scaffold
- `docs/` — methodological protocol and measurement notes
- `outputs/` — generated model outputs and summaries

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
python3 python/hci_cognition_model.py --simulate --output data/hci_trials.csv --outputs outputs
python3 python/hci_cognition_model.py --input data/hci_trials.csv --outputs outputs
Rscript r/hci_cognition_analysis.R data/hci_trials.csv outputs
go run go/validator.go data/hci_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/hci_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognition-human-computer-interaction
