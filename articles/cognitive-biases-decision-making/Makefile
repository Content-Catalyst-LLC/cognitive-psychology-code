.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-confirmation fortran-calibration julia-prospect all clean

python-generate:
	python3 python/cognitive_bias_model.py --simulate --output data/cognitive_bias_trials.csv --outputs outputs

python-model:
	python3 python/cognitive_bias_model.py --input data/cognitive_bias_trials.csv --outputs outputs

r-analysis:
	Rscript r/cognitive_bias_analysis.R data/cognitive_bias_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/cognitive_bias_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/cognitive_bias_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-confirmation:
	$(MAKE) -C cpp run

fortran-calibration:
	$(MAKE) -C fortran run

julia-prospect:
	cd julia && julia prospect_theory_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-confirmation fortran-calibration

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
