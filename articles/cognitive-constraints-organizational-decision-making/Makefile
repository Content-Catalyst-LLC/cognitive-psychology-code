.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-ddm fortran-sdm julia-sim all clean

python-generate:
	python3 python/cognitive_constraints_model.py --simulate --output data/organizational_decision_trials.csv --outputs outputs

python-model:
	python3 python/cognitive_constraints_model.py --input data/organizational_decision_trials.csv --outputs outputs

r-analysis:
	Rscript r/cognitive_constraints_analysis.R data/organizational_decision_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/organizational_decision_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/organizational_decision_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-ddm:
	$(MAKE) -C cpp run

fortran-sdm:
	$(MAKE) -C fortran run

julia-sim:
	cd julia && julia cognitive_constraint_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-ddm fortran-sdm

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
