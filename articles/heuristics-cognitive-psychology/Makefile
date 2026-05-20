.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-adaptive fortran-effort julia-fast all clean

python-generate:
	python3 python/heuristics_model.py --simulate --output data/heuristics_trials.csv --outputs outputs

python-model:
	python3 python/heuristics_model.py --input data/heuristics_trials.csv --outputs outputs

r-analysis:
	Rscript r/heuristics_analysis.R data/heuristics_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/heuristics_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/heuristics_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-adaptive:
	$(MAKE) -C cpp run

fortran-effort:
	$(MAKE) -C fortran run

julia-fast:
	cd julia && julia fast_and_frugal_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-adaptive fortran-effort

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
