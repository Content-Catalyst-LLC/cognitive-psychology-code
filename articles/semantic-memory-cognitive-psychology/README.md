# Semantic Memory in Cognitive Psychology

This folder contains reproducible research code for studying semantic memory in cognitive psychology. The examples are designed for cognitive psychologists, memory researchers, psycholinguists, cognitive neuroscientists, AI researchers, knowledge-engineering researchers, learning scientists, and computational cognitive scientists studying conceptual knowledge, semantic networks, category structure, fact verification, semantic distance, spreading activation, feature overlap, schema organization, retrieval latency, and semantic decision making.

## Research focus

The code operationalizes semantic memory through:

- semantic distance
- category typicality
- feature overlap
- associative strength
- category membership
- fact truth
- retrieval cue strength
- concept familiarity
- concept concreteness
- semantic relatedness
- spreading activation
- verification accuracy
- category-strength ratings
- retrieval response time
- false semantic association
- schema consistency

The repository supports simulation, statistical modeling, validation, semantic-network analysis, spreading-activation simulation, category-verification models, semantic-distance effects, response-time modeling, computational memory representations, experimental summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, semantic-memory modeling, network analysis, and plots
- `r/` — hierarchical modeling and tidyverse workflow for semantic-memory experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — spreading-activation and semantic-distance simulation
- `c` — fast semantic-network activation simulator
- `cpp` — category-verification and retrieval-cost simulation
- `fortran` — signal-detection-style model for semantic verification
- `go` — CSV validation utility for semantic-memory datasets
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
python3 python/semantic_memory_model.py --simulate --output data/semantic_memory_trials.csv --outputs outputs
python3 python/semantic_memory_model.py --input data/semantic_memory_trials.csv --outputs outputs
Rscript r/semantic_memory_analysis.R data/semantic_memory_trials.csv outputs
go run go/validator.go data/semantic_memory_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/semantic_memory_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/semantic-memory-cognitive-psychology
