.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-transfer fortran-learning julia-transfer all clean

python-generate:
	python3 python/cognitive_learning_model.py --simulate --output data/cognitive_learning_trials.csv --outputs outputs

python-model:
	python3 python/cognitive_learning_model.py --input data/cognitive_learning_trials.csv --outputs outputs

r-analysis:
	Rscript r/cognitive_learning_analysis.R data/cognitive_learning_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/cognitive_learning_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/cognitive_learning_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-transfer:
	$(MAKE) -C cpp run

fortran-learning:
	$(MAKE) -C fortran run

julia-transfer:
	cd julia && julia encoding_transfer_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-transfer fortran-learning

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
