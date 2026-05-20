.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-exemplar fortran-discrimination julia-prototype all clean

python-generate:
	python3 python/concept_formation_model.py --simulate --output data/concept_formation_trials.csv --outputs outputs

python-model:
	python3 python/concept_formation_model.py --input data/concept_formation_trials.csv --outputs outputs

r-analysis:
	Rscript r/concept_formation_analysis.R data/concept_formation_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/concept_formation_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/concept_formation_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-exemplar:
	$(MAKE) -C cpp run

fortran-discrimination:
	$(MAKE) -C fortran run

julia-prototype:
	cd julia && julia prototype_exemplar_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-exemplar fortran-discrimination

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
