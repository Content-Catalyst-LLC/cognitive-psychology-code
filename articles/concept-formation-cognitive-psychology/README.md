# Concept Formation in Cognitive Psychology

This folder contains reproducible research code for studying concept formation and categorization in cognitive psychology. The examples are designed for cognitive psychologists, learning scientists, psycholinguists, developmental researchers, AI researchers, education researchers, decision scientists, and computational cognitive scientists studying abstraction, category learning, prototype effects, exemplar memory, boundary discrimination, feature weighting, generalization, transfer, category typicality, and conceptual change.

## Research focus

The code operationalizes concept formation through:

- prototype distance
- exemplar similarity
- category typicality
- feature diagnosticity
- feature overlap
- boundary ambiguity
- rule consistency
- feedback availability
- category accuracy
- generalization score
- discrimination score
- concept confidence
- response time
- overgeneralization error
- conceptual flexibility
- abstraction quality

The repository supports simulation, statistical modeling, validation, prototype and exemplar models, category-learning simulations, boundary-discrimination studies, generalization analysis, response-time modeling, computational concept representations, experimental summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, concept-formation modeling, prototype/exemplar analysis, and plots
- `r/` — hierarchical modeling and tidyverse workflow for concept-formation experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — prototype, exemplar, and category-boundary simulation
- `c` — fast prototype-distance categorization simulator
- `cpp` — exemplar-memory and boundary-classification simulation
- `fortran` — signal-detection-style model for category discrimination
- `go` — CSV validation utility for concept-formation datasets
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
python3 python/concept_formation_model.py --simulate --output data/concept_formation_trials.csv --outputs outputs
python3 python/concept_formation_model.py --input data/concept_formation_trials.csv --outputs outputs
Rscript r/concept_formation_analysis.R data/concept_formation_trials.csv outputs
go run go/validator.go data/concept_formation_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/concept_formation_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/concept-formation-cognitive-psychology
