.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-sentence fortran-comprehension julia-parsing all clean

python-generate:
	python3 python/language_processing_model.py --simulate --output data/language_processing_trials.csv --outputs outputs

python-model:
	python3 python/language_processing_model.py --input data/language_processing_trials.csv --outputs outputs

r-analysis:
	Rscript r/language_processing_analysis.R data/language_processing_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/language_processing_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/language_processing_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-sentence:
	$(MAKE) -C cpp run

fortran-comprehension:
	$(MAKE) -C fortran run

julia-parsing:
	cd julia && julia incremental_parsing_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-sentence fortran-comprehension

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
