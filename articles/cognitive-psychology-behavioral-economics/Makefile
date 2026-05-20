.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-choice fortran-risk julia-prospect all clean

python-generate:
	python3 python/behavioral_economics_model.py --simulate --output data/behavioral_economics_trials.csv --outputs outputs

python-model:
	python3 python/behavioral_economics_model.py --input data/behavioral_economics_trials.csv --outputs outputs

r-analysis:
	Rscript r/behavioral_economics_analysis.R data/behavioral_economics_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/behavioral_economics_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/behavioral_economics_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-choice:
	$(MAKE) -C cpp run

fortran-risk:
	$(MAKE) -C fortran run

julia-prospect:
	cd julia && julia prospect_choice_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-choice fortran-risk

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
