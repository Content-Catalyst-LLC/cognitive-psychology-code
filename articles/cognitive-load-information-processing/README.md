# Cognitive Load and Information Processing

This folder contains reproducible research code for studying cognitive load in cognitive psychology, instructional design, human factors, HCI, medical education, decision science, and human-AI interaction. The examples are designed for researchers studying working-memory limits, intrinsic load, extraneous load, germane processing, element interactivity, split attention, redundancy, expertise reversal, subjective effort, task workload, performance accuracy, response time, transfer, learning gain, and instructional efficiency.

## Research focus

The code operationalizes cognitive load through:

- intrinsic load
- extraneous load
- germane load
- element interactivity
- prior knowledge
- working-memory capacity
- design quality
- split-attention burden
- redundancy burden
- subjective mental effort
- NASA-TLX-style workload dimensions
- performance accuracy
- correct response
- response time
- error rate
- transfer score
- learning gain
- mental efficiency
- confidence
- overload probability

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, load-performance models, efficiency metrics, and plots
- `r/` — hierarchical modeling workflow for cognitive-load experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — nonlinear load-capacity simulation
- `c` — fast overload simulator
- `cpp` — instructional-design and expertise-reversal simulator
- `fortran` — workload-threshold model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/cognitive_load_model.py --simulate --output data/cognitive_load_trials.csv --outputs outputs
python3 python/cognitive_load_model.py --input data/cognitive_load_trials.csv --outputs outputs
Rscript r/cognitive_load_analysis.R data/cognitive_load_trials.csv outputs
go run go/validator.go data/cognitive_load_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/cognitive_load_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognitive-load-information-processing
