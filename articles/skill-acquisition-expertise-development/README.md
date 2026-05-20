# Skill Acquisition and Expertise Development

Research code for studying skill acquisition, deliberate practice, feedback, learning curves, error reduction, cognitive load, automaticity, transfer, retention, adaptive expertise, and novice-expert differences.

Repository URL:

https://github.com/Content-Catalyst-LLC/cognitive-psychology-code/tree/main/articles/skill-acquisition-expertise-development

## Quick start

```bash
python3 python/skill_acquisition_model.py --simulate --output data/skill_acquisition_trials.csv --outputs outputs
python3 python/skill_acquisition_model.py --input data/skill_acquisition_trials.csv --outputs outputs
Rscript r/skill_acquisition_analysis.R data/skill_acquisition_trials.csv outputs
sqlite3 outputs/skill_acquisition.db < sql/skill_acquisition_schema.sql
go run go/validator.go data/skill_acquisition_trials.csv
cargo run --manifest-path rust/Cargo.toml -- data/skill_acquisition_trials.csv
make all
```

## Research variables

The sample workflow includes expertise level, practice session, deliberate-practice quality, feedback quality, task difficulty, cognitive load, working-memory demand, chunking, pattern recognition, strategy quality, transfer, adaptive flexibility, accuracy, error rate, response time, automaticity, and retention.
