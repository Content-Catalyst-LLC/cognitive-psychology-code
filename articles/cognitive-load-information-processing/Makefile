.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-expertise fortran-workload julia-load all clean

python-generate:
	python3 python/cognitive_load_model.py --simulate --output data/cognitive_load_trials.csv --outputs outputs

python-model:
	python3 python/cognitive_load_model.py --input data/cognitive_load_trials.csv --outputs outputs

r-analysis:
	Rscript r/cognitive_load_analysis.R data/cognitive_load_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/cognitive_load_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/cognitive_load_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-expertise:
	$(MAKE) -C cpp run

fortran-workload:
	$(MAKE) -C fortran run

julia-load:
	cd julia && julia load_capacity_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-expertise fortran-workload

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
