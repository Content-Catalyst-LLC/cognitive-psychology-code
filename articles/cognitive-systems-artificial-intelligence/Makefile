.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-production fortran-calibration julia-policy all clean

python-generate:
	python3 python/cognitive_systems_ai_model.py --simulate --output data/cognitive_systems_trials.csv --outputs outputs

python-model:
	python3 python/cognitive_systems_ai_model.py --input data/cognitive_systems_trials.csv --outputs outputs

r-analysis:
	Rscript r/cognitive_systems_ai_analysis.R data/cognitive_systems_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/cognitive_systems_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/cognitive_systems_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-production:
	$(MAKE) -C cpp run

fortran-calibration:
	$(MAKE) -C fortran run

julia-policy:
	cd julia && julia cognitive_system_policy_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-production fortran-calibration

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
