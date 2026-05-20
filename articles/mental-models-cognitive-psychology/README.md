# Mental Models in Cognitive Psychology

This folder contains reproducible research code for studying mental models in cognitive psychology. The examples are designed for cognitive psychologists, reasoning researchers, learning scientists, human factors researchers, HCI researchers, systems researchers, decision scientists, AI researchers, and computational cognitive scientists studying model quality, causal structure, prediction error, system understanding, reasoning performance, conceptual change, mental-model revision, and human-AI decision support.

## Research focus

The code operationalizes mental models through:

- model completeness
- model coherence
- causal-link accuracy
- feedback-loop recognition
- boundary accuracy
- prediction error
- system-understanding score
- problem-solving success
- reasoning time
- confidence
- cognitive load
- model-revision score
- transfer score
- structural similarity
- explanation quality
- intervention choice accuracy

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, prediction-error models, reasoning-success models, and plots
- `r/` — hierarchical modeling workflow for mental-model experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — system-state prediction and model-revision simulation
- `c` — fast prediction-error simulator
- `cpp` — causal-network and intervention simulation
- `fortran` — signal-detection-style model-quality simulator
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/mental_models_model.py --simulate --output data/mental_models_trials.csv --outputs outputs
python3 python/mental_models_model.py --input data/mental_models_trials.csv --outputs outputs
Rscript r/mental_models_analysis.R data/mental_models_trials.csv outputs
go run go/validator.go data/mental_models_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/mental_models_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/mental-models-cognitive-psychology
