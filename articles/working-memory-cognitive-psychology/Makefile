.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-updating fortran-load julia-gating all clean

python-generate:
	python3 python/working_memory_model.py --simulate --output data/working_memory_trials.csv --outputs outputs

python-model:
	python3 python/working_memory_model.py --input data/working_memory_trials.csv --outputs outputs

r-analysis:
	Rscript r/working_memory_analysis.R data/working_memory_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/working_memory_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/working_memory_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-updating:
	$(MAKE) -C cpp run

fortran-load:
	$(MAKE) -C fortran run

julia-gating:
	cd julia && julia capacity_gating_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-updating fortran-load

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
