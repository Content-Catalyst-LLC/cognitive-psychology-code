# Analogical Reasoning and Knowledge Transfer

This folder contains reproducible research code for studying analogical reasoning and knowledge transfer. The examples are designed for cognitive psychologists, learning scientists, education researchers, decision scientists, AI researchers, legal-reasoning scholars, and computational cognitive scientists studying source retrieval, relational mapping, transfer success, structural alignment, relational complexity, analogical inference, schema abstraction, and cross-domain learning.

## Research focus

The code operationalizes analogical reasoning through:

- source familiarity
- target novelty
- relational complexity
- surface similarity
- structural similarity
- mapping accuracy
- transfer success
- inference quality
- schema abstraction
- working-memory load
- source retrieval latency
- analogical confidence
- response time

The repository supports simulation, statistical modeling, validation, structure-mapping scores, relational-similarity measures, transfer-success models, response-time modeling, experimental summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, analogical-transfer modeling, mapping-quality summaries, and plots
- `r/` — hierarchical modeling and tidyverse workflow for analogical-reasoning experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — structure-mapping and relational-transfer simulation
- `c` — fast relational-fit simulator
- `cpp` — candidate source retrieval and mapping simulation
- `fortran` — signal-detection-style model for relational-match detection
- `go` — CSV validation utility for analogy datasets
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated model outputs and summaries

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
python3 python/analogical_reasoning_model.py --simulate --output data/analogical_reasoning_trials.csv --outputs outputs
python3 python/analogical_reasoning_model.py --input data/analogical_reasoning_trials.csv --outputs outputs
Rscript r/analogical_reasoning_analysis.R data/analogical_reasoning_trials.csv outputs
go run go/validator.go data/analogical_reasoning_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/analogical_reasoning_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/analogical-reasoning-and-knowledge-transfer
