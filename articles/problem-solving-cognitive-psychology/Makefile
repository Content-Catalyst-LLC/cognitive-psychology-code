.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-strategy fortran-progress julia-state all clean

python-generate:
	python3 python/problem_solving_model.py --simulate --output data/problem_solving_trials.csv --outputs outputs

python-model:
	python3 python/problem_solving_model.py --input data/problem_solving_trials.csv --outputs outputs

r-analysis:
	Rscript r/problem_solving_analysis.R data/problem_solving_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/problem_solving_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/problem_solving_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-strategy:
	$(MAKE) -C cpp run

fortran-progress:
	$(MAKE) -C fortran run

julia-state:
	cd julia && julia state_space_strategy_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-strategy fortran-progress

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
