# Metacognition: Thinking About Thinking

This folder contains reproducible research code for studying metacognition in cognitive psychology. The examples are designed for cognitive psychologists, educational psychologists, learning scientists, decision researchers, human factors researchers, AI researchers, and computational cognitive scientists studying confidence, calibration, monitoring, control, strategy selection, judgments of learning, error detection, uncertainty awareness, and self-regulated learning.

## Research focus

The code operationalizes metacognition through:

- confidence rating
- actual accuracy
- calibration error
- overconfidence
- underconfidence
- monitoring sensitivity
- task difficulty
- uncertainty rating
- judgment of learning
- feeling of knowing
- strategy shift
- study-time allocation
- review choice
- response time
- feedback use
- metacognitive regulation score

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, calibration models, strategy-shift models, and plots
- `r/` — hierarchical modeling workflow for metacognition experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — monitoring-control simulation
- `c` — fast calibration simulator
- `cpp` — strategy-control and study-allocation simulation
- `fortran` — signal-detection-style metacognitive sensitivity model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/metacognition_model.py --simulate --output data/metacognition_trials.csv --outputs outputs
python3 python/metacognition_model.py --input data/metacognition_trials.csv --outputs outputs
Rscript r/metacognition_analysis.R data/metacognition_trials.csv outputs
go run go/validator.go data/metacognition_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/metacognition_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/metacognition-thinking-about-thinking
