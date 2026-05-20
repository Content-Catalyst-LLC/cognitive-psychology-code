# Attention in Cognitive Psychology

This folder contains reproducible research code for studying attention in cognitive psychology, cognitive neuroscience, human factors, HCI, education, safety, decision science, and human-AI systems.

The examples support work on cueing, orienting, selection, vigilance, sustained attention, divided attention, executive control, attention switching, signal detection, visual search, response time, attentional load, confidence, distraction, salience, goal relevance, target prevalence, and attentional lapses.

## Research focus

The code operationalizes attention through:

- condition
- cue validity
- target presence
- response
- correctness
- reaction time
- block/time-on-task
- salience
- goal relevance
- distractor load
- perceptual load
- executive load
- task switch
- conflict
- vigilance state
- lapse probability
- hit rate
- false alarm rate
- d-prime
- criterion
- orienting benefit
- reorienting cost
- divided-attention cost
- interface salience
- notification load
- confidence

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, signal detection, cueing effects, vigilance models, RT models, and DDM-style simulation
- `r/` — hierarchical modeling workflow for attention experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — vigilance and drift-diffusion style simulation
- `c/` — fast vigilance simulator
- `cpp/` — visual-search and attentional-priority simulator
- `fortran/` — signal-detection and lapse model
- `go/` — CSV validation utility
- `rust/` — fast summary and data-quality utility
- `notebooks/` — notebook workflow scaffold
- `docs/` — methodological protocol and measurement notes
- `outputs/` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/attention_model.py --simulate --output data/attention_trials.csv --outputs outputs
python3 python/attention_model.py --input data/attention_trials.csv --outputs outputs
Rscript r/attention_analysis.R data/attention_trials.csv outputs
go run go/validator.go data/attention_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/attention_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/attention-cognitive-psychology
