.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-amplification fortran-risk julia-prospect all clean

python-generate:
	python3 python/risk_perception_model.py --simulate --output data/risk_perception_trials.csv --outputs outputs

python-model:
	python3 python/risk_perception_model.py --input data/risk_perception_trials.csv --outputs outputs

r-analysis:
	Rscript r/risk_perception_analysis.R data/risk_perception_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/risk_perception_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/risk_perception_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-amplification:
	$(MAKE) -C cpp run

fortran-risk:
	$(MAKE) -C fortran run

julia-prospect:
	cd julia && julia prospect_weighting_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-amplification fortran-risk

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
