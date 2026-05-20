# Working Memory in Cognitive Psychology

This folder contains reproducible research code for studying working memory in cognitive psychology, cognitive neuroscience, education, human factors, language processing, decision making, and human-AI interaction. The examples are designed for researchers studying working-memory capacity, span tasks, complex span, n-back updating, serial recall, interference, attentional control, cognitive load, modality-specific storage, chunking, dual-task costs, response time, accuracy, and individual differences.

## Research focus

The code operationalizes working memory through:

- task condition
- task type
- memory load
- serial position
- modality
- distractor level
- interference
- attentional control
- updating demand
- storage demand
- processing demand
- chunking support
- rehearsal opportunity
- cognitive load
- span score
- updating score
- recall accuracy
- response time
- capacity estimate
- overload probability
- dual-task cost
- confidence
- learning support
- interface complexity

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, capacity models, span/updating analysis, and plots
- `r/` — hierarchical modeling workflow for working-memory experiments
- `sql` — relational schema, analytical views, and reproducible SQL queries
- `julia` — capacity-limit and gating simulation
- `c` — fast span-capacity simulator
- `cpp` — updating and interference simulator
- `fortran` — load-accuracy model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/working_memory_model.py --simulate --output data/working_memory_trials.csv --outputs outputs
python3 python/working_memory_model.py --input data/working_memory_trials.csv --outputs outputs
Rscript r/working_memory_analysis.R data/working_memory_trials.csv outputs
go run go/validator.go data/working_memory_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/working_memory_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/working-memory-cognitive-psychology
