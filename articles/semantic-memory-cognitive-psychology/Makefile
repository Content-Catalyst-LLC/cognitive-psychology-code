.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-category fortran-semantic julia-activation all clean

python-generate:
	python3 python/semantic_memory_model.py --simulate --output data/semantic_memory_trials.csv --outputs outputs

python-model:
	python3 python/semantic_memory_model.py --input data/semantic_memory_trials.csv --outputs outputs

r-analysis:
	Rscript r/semantic_memory_analysis.R data/semantic_memory_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/semantic_memory_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/semantic_memory_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-category:
	$(MAKE) -C cpp run

fortran-semantic:
	$(MAKE) -C fortran run

julia-activation:
	cd julia && julia spreading_activation_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-category fortran-semantic

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
