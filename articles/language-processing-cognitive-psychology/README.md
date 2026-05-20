# Language Processing in Cognitive Psychology

This folder contains reproducible research code for studying language processing in cognitive psychology. The examples are designed for cognitive psychologists, psycholinguists, language scientists, literacy researchers, cognitive neuroscientists, AI researchers, speech-language researchers, human-computer interaction researchers, and computational cognitive scientists studying lexical access, syntactic parsing, semantic integration, pragmatic inference, working-memory load, reading time, lexical decision, comprehension accuracy, production latency, discourse coherence, and language-mediated meaning construction.

## Research focus

The code operationalizes language processing through:

- modality
- word frequency
- lexical ambiguity
- syntactic complexity
- semantic predictability
- context support
- working-memory load
- pragmatic inference demand
- discourse coherence
- comprehension accuracy
- lexical decision accuracy
- production accuracy
- reading time
- lexical decision response time
- production latency
- confidence

The repository supports simulation, statistical modeling, validation, lexical-decision analysis, reading-time analysis, comprehension models, production-latency models, incremental parsing simulations, sentence-processing experiments, discourse-context analysis, experimental summaries, and reproducible documentation.

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, language-processing modeling, lexical/reading-time analysis, and plots
- `r/` — hierarchical modeling and tidyverse workflow for language-processing experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — incremental comprehension and parsing-cost simulation
- `c` — fast lexical-access and reading-time simulator
- `cpp` — sentence-processing and ambiguity-resolution simulation
- `fortran` — signal-detection-style model for comprehension under noise and ambiguity
- `go` — CSV validation utility for language-processing datasets
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
python3 python/language_processing_model.py --simulate --output data/language_processing_trials.csv --outputs outputs
python3 python/language_processing_model.py --input data/language_processing_trials.csv --outputs outputs
Rscript r/language_processing_analysis.R data/language_processing_trials.csv outputs
go run go/validator.go data/language_processing_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/language_processing_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/language-processing-cognitive-psychology
