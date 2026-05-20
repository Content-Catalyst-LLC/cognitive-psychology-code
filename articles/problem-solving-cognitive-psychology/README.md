# Problem Solving in Cognitive Psychology

This folder contains reproducible research code for studying problem solving in cognitive psychology. The examples are designed for cognitive psychologists, learning scientists, decision scientists, human factors researchers, education researchers, AI researchers, organizational researchers, and computational cognitive scientists studying problem representation, state-space search, strategy selection, working-memory load, metacognitive monitoring, uncertainty, transfer, insight, and solution accuracy.

## Research focus

The code operationalizes problem solving through:

- problem difficulty
- problem representation quality
- goal clarity
- constraint load
- working-memory load
- strategy type
- heuristic reliance
- means-end analysis
- analogical support
- insight event
- strategy switching
- metacognitive monitoring
- solution accuracy
- solution quality
- response time
- error count

The repository supports simulation, statistical modeling, validation, state-space search models, strategy-selection models, working-memory load analysis, response-time modeling, problem-representation studies, experimental summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, problem-solving modeling, strategy analysis, and plots
- `r/` — hierarchical modeling and tidyverse workflow for problem-solving experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — state-space search and strategy-selection simulation
- `c` — fast means-end search simulator
- `cpp` — strategy-selection and search-cost simulation
- `fortran` — signal-detection-style model for impasse and progress monitoring
- `go` — CSV validation utility for problem-solving datasets
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
python3 python/problem_solving_model.py --simulate --output data/problem_solving_trials.csv --outputs outputs
python3 python/problem_solving_model.py --input data/problem_solving_trials.csv --outputs outputs
Rscript r/problem_solving_analysis.R data/problem_solving_trials.csv outputs
go run go/validator.go data/problem_solving_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/problem_solving_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/problem-solving-cognitive-psychology
