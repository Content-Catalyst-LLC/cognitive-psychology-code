# Sensory Memory in Cognitive Psychology

This folder contains reproducible research code for studying sensory memory in cognitive psychology. The examples are designed for cognitive psychologists, perception researchers, auditory researchers, vision scientists, haptics researchers, human factors researchers, HCI researchers, neuroscience researchers, and computational cognitive scientists studying iconic memory, echoic memory, haptic memory, partial report, cue delay, trace decay, sensory persistence, selection, masking, report accuracy, response time, and transfer to working memory.

## Research focus

The code operationalizes sensory memory through:

- modality
- cue delay
- stimulus duration
- array size
- mask condition
- cue validity
- trace strength
- salience
- attentional priority
- report score
- correct report
- partial-report advantage
- decay rate
- selection probability
- working-memory transfer
- response time
- confidence
- perceptual continuity

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, sensory-trace decay models, accuracy models, and plots
- `r/` — hierarchical modeling workflow for sensory-memory experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — multimodal sensory-trace decay simulation
- `c` — fast iconic-memory decay simulator
- `cpp` — partial-report and selection simulator
- `fortran` — modality-specific signal persistence model
- `go` — CSV validation utility
- `rust` — fast summary and data-quality utility
- `notebooks` — notebook workflow scaffold
- `docs` — methodological protocol and measurement notes
- `outputs` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/sensory_memory_model.py --simulate --output data/sensory_memory_trials.csv --outputs outputs
python3 python/sensory_memory_model.py --input data/sensory_memory_trials.csv --outputs outputs
Rscript r/sensory_memory_analysis.R data/sensory_memory_trials.csv outputs
go run go/validator.go data/sensory_memory_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/sensory_memory_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/sensory-memory-cognitive-psychology
