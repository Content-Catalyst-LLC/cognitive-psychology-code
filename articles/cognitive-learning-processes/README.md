# Cognitive Learning Processes

This folder contains reproducible research code for studying cognitive learning processes in cognitive psychology. The examples are designed for cognitive psychologists, learning scientists, educational researchers, instructional designers, human factors researchers, AI researchers, and computational cognitive scientists studying attention, encoding, retrieval, prior knowledge, schema formation, cognitive load, feedback, transfer, retention, retrieval practice, worked examples, spacing, interleaving, and knowledge application.

## Research focus

The code operationalizes cognitive learning through:

- prior knowledge
- attention score
- encoding quality
- working-memory load
- schema strength
- retrieval practice
- feedback quality
- cognitive load
- transfer score
- retention score
- accuracy
- response time
- comprehension score
- learning gain
- adaptive application

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, learning-growth models, transfer models, and plots
- `r/` — hierarchical modeling workflow for cognitive-learning experiments
- `sql` — relational schema, analytical views, and reproducible SQL queries
- `julia` — encoding, integration, and transfer simulation
- `c` — fast learning-curve simulator
- `cpp` — retrieval-practice and transfer simulation
- `fortran` — signal-detection-style learning sensitivity model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/cognitive_learning_model.py --simulate --output data/cognitive_learning_trials.csv --outputs outputs
python3 python/cognitive_learning_model.py --input data/cognitive_learning_trials.csv --outputs outputs
Rscript r/cognitive_learning_analysis.R data/cognitive_learning_trials.csv outputs
go run go/validator.go data/cognitive_learning_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/cognitive_learning_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/cognitive-learning-processes
