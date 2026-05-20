.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-misinfo fortran-retention julia-forgetting all clean

python-generate:
	python3 python/memory_model.py --simulate --output data/memory_trials.csv --outputs outputs

python-model:
	python3 python/memory_model.py --input data/memory_trials.csv --outputs outputs

r-analysis:
	Rscript r/memory_analysis.R data/memory_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/memory_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/memory_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-misinfo:
	$(MAKE) -C cpp run

fortran-retention:
	$(MAKE) -C fortran run

julia-forgetting:
	cd julia && julia forgetting_retrieval_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-misinfo fortran-retention

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
