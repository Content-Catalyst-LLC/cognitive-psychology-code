.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-interventions fortran-quality julia-revision all clean

python-generate:
	python3 python/mental_models_model.py --simulate --output data/mental_models_trials.csv --outputs outputs

python-model:
	python3 python/mental_models_model.py --input data/mental_models_trials.csv --outputs outputs

r-analysis:
	Rscript r/mental_models_analysis.R data/mental_models_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/mental_models_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/mental_models_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-interventions:
	$(MAKE) -C cpp run

fortran-quality:
	$(MAKE) -C fortran run

julia-revision:
	cd julia && julia model_revision_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-interventions fortran-quality

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
