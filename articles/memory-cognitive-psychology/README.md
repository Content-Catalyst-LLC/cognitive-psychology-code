# Memory in Cognitive Psychology

This folder contains reproducible research code for studying memory in cognitive psychology, cognitive neuroscience, education, law, human factors, and human-AI interaction.

## Research focus

The workflows support analysis of encoding depth, retention, consolidation, forgetting, retrieval cues, recognition memory, signal detection, interference, misinformation, retrieval practice, spacing, source monitoring, constructive memory, semantic/episodic distinctions, response time, confidence, and learning transfer.

## Folder structure

- `data/` — sample data and data dictionary
- `python/` — synthetic data generation, recognition-memory analysis, forgetting curves, retrieval-practice models
- `r/` — hierarchical modeling workflow
- `sql/` — relational schema and analytical views
- `julia/` — forgetting and retrieval-practice simulation
- `c/` — fast exponential and power-law forgetting simulator
- `cpp/` — misinformation/source-monitoring simulator
- `fortran/` — retention/interference model
- `go/` — CSV validation utility
- `rust/` — fast summary utility
- `notebooks/` — notebook scaffold
- `docs/` — protocol and measurement notes
- `outputs/` — generated summaries and model outputs

## Example commands

```bash
python3 python/memory_model.py --simulate --output data/memory_trials.csv --outputs outputs
python3 python/memory_model.py --input data/memory_trials.csv --outputs outputs
Rscript r/memory_analysis.R data/memory_trials.csv outputs
go run go/validator.go data/memory_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/memory_trials.csv
make all
```

Repository:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/memory-cognitive-psychology
