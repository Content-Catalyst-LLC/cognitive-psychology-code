# Perception in Cognitive Psychology

This folder contains reproducible research code for studying perception in cognitive psychology, psychophysics, cognitive neuroscience, human-computer interaction, human factors, vision science, auditory perception, multisensory integration, and human-AI systems.

The examples support work on sensory evidence, stimulus intensity, signal detection, psychometric functions, perceptual threshold, just-noticeable difference, perceptual uncertainty, cue quality, attention gain, prior expectation, context strength, prediction error, multisensory congruence, visual search, figure-ground structure, object recognition, confidence, response time, and perceptual learning.

## Research focus

The code operationalizes perception through:

- condition
- modality
- stimulus level
- signal presence
- response
- correctness
- sensory evidence
- prior expectation
- cue quality
- attention gain
- context strength
- noise level
- prediction error
- perceptual threshold
- d-prime
- criterion
- response time
- confidence
- multisensory congruence
- visual search set size
- distractor similarity
- perceptual learning block
- interface salience

## Folder structure

- `data/` — sample data, data dictionary, and expected schema
- `python/` — synthetic data generation, psychometric analysis, signal detection, prediction-error modeling, and plots
- `r/` — hierarchical modeling workflow for perceptual experiments
- `sql/` — relational schema, analytical views, and reproducible SQL queries
- `julia/` — Bayesian/predictive perceptual inference simulation
- `c/` — fast psychometric-threshold simulator
- `cpp/` — visual-search and feature-integration simulator
- `fortran/` — signal-detection model
- `go/` — CSV validation utility
- `rust/` — fast summary and data-quality utility
- `notebooks/` — notebook workflow scaffold
- `docs/` — methodological protocol and measurement notes
- `outputs/` — generated summaries and model outputs

## Example commands

From this article folder:

```bash
python3 python/perception_model.py --simulate --output data/perception_trials.csv --outputs outputs
python3 python/perception_model.py --input data/perception_trials.csv --outputs outputs
Rscript r/perception_analysis.R data/perception_trials.csv outputs
go run go/validator.go data/perception_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/perception_trials.csv
make all
```

## Repository link

Article code directory:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/perception-cognitive-psychology
