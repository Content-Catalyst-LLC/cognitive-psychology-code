.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-study fortran-sensitivity julia-monitoring all clean

python-generate:
	python3 python/metacognition_model.py --simulate --output data/metacognition_trials.csv --outputs outputs

python-model:
	python3 python/metacognition_model.py --input data/metacognition_trials.csv --outputs outputs

r-analysis:
	Rscript r/metacognition_analysis.R data/metacognition_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/metacognition_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/metacognition_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-study:
	$(MAKE) -C cpp run

fortran-sensitivity:
	$(MAKE) -C fortran run

julia-monitoring:
	cd julia && julia monitoring_control_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-study fortran-sensitivity

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
