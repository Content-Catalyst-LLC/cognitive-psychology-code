.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-evidence fortran-threshold julia-ddm all clean

python-generate:
	python3 python/decision_model.py --simulate --output data/decision_trials.csv --outputs outputs

python-model:
	python3 python/decision_model.py --input data/decision_trials.csv --outputs outputs

r-analysis:
	Rscript r/decision_analysis.R data/decision_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/decision_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/decision_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-evidence:
	$(MAKE) -C cpp run

fortran-threshold:
	$(MAKE) -C fortran run

julia-ddm:
	cd julia && julia drift_diffusion_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-evidence fortran-threshold

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
