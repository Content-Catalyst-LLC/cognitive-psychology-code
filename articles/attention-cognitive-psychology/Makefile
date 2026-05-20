.PHONY: python-generate python-model r-analysis go-validate rust-summary c-vigilance cpp-priority fortran-lapse julia-vigilance all clean

python-generate:
	python3 python/attention_model.py --simulate --output data/attention_trials.csv --outputs outputs

python-model:
	python3 python/attention_model.py --input data/attention_trials.csv --outputs outputs

r-analysis:
	Rscript r/attention_analysis.R data/attention_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/attention_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/attention_trials.csv

c-vigilance:
	$(MAKE) -C c run

cpp-priority:
	$(MAKE) -C cpp run

fortran-lapse:
	$(MAKE) -C fortran run

julia-vigilance:
	cd julia && julia vigilance_ddm_simulation.jl

all: python-generate python-model go-validate rust-summary c-vigilance cpp-priority fortran-lapse

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
