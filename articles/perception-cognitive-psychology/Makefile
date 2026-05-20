.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-search fortran-sdt julia-bayes all clean

python-generate:
	python3 python/perception_model.py --simulate --output data/perception_trials.csv --outputs outputs

python-model:
	python3 python/perception_model.py --input data/perception_trials.csv --outputs outputs

r-analysis:
	Rscript r/perception_analysis.R data/perception_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/perception_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/perception_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-search:
	$(MAKE) -C cpp run

fortran-sdt:
	$(MAKE) -C fortran run

julia-bayes:
	cd julia && julia bayesian_perception_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-search fortran-sdt

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
