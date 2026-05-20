.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-retrieval fortran-match julia-mapping all clean

python-generate:
	python3 python/analogical_reasoning_model.py --simulate --output data/analogical_reasoning_trials.csv --outputs outputs

python-model:
	python3 python/analogical_reasoning_model.py --input data/analogical_reasoning_trials.csv --outputs outputs

r-analysis:
	Rscript r/analogical_reasoning_analysis.R data/analogical_reasoning_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/analogical_reasoning_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/analogical_reasoning_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-retrieval:
	$(MAKE) -C cpp run

fortran-match:
	$(MAKE) -C fortran run

julia-mapping:
	cd julia && julia structure_mapping_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-retrieval fortran-match

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
