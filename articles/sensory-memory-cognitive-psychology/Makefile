.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-partial fortran-persistence julia-decay all clean

python-generate:
	python3 python/sensory_memory_model.py --simulate --output data/sensory_memory_trials.csv --outputs outputs

python-model:
	python3 python/sensory_memory_model.py --input data/sensory_memory_trials.csv --outputs outputs

r-analysis:
	Rscript r/sensory_memory_analysis.R data/sensory_memory_trials.csv outputs

go-validate:
	cd go && go run validator.go ../data/sensory_memory_trials.csv

rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/sensory_memory_trials.csv

c-sim:
	$(MAKE) -C c run

cpp-partial:
	$(MAKE) -C cpp run

fortran-persistence:
	$(MAKE) -C fortran run

julia-decay:
	cd julia && julia sensory_trace_decay_simulation.jl

all: python-generate python-model go-validate rust-summary c-sim cpp-partial fortran-persistence

clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
