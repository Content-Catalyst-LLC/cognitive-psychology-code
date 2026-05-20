.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-fitts fortran-warning julia-load all clean

python-generate:
	python3 python/hci_cognition_model.py --simulate --output data/hci_trials.csv --outputs outputs

python-model:
	python3 python/hci_cognition_model.py --input data/hci_trials.csv --outputs outputs

r-analysis:
	Rscript r/hci_cognition_analysis.R data/hci_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/hci_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/hci_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-fitts:
	$(MAKE) -C cpp run

fortran-warning:
	$(MAKE) -C fortran run

julia-load:
	cd julia && julia hci_cognitive_load_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-fitts fortran-warning

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
