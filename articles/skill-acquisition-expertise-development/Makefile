.PHONY: python-generate python-model r-analysis go-validate rust-summary c-sim cpp-transfer fortran-expertise julia-learning all clean
python-generate:
	python3 python/skill_acquisition_model.py --simulate --output data/skill_acquisition_trials.csv --outputs outputs
python-model:
	python3 python/skill_acquisition_model.py --input data/skill_acquisition_trials.csv --outputs outputs
r-analysis:
	Rscript r/skill_acquisition_analysis.R data/skill_acquisition_trials.csv outputs
go-validate:
	cd go && go run validator.go ../data/skill_acquisition_trials.csv
rust-summary:
	cargo run --manifest-path rust/Cargo.toml -- data/skill_acquisition_trials.csv
c-sim:
	$(MAKE) -C c run
cpp-transfer:
	$(MAKE) -C cpp run
fortran-expertise:
	$(MAKE) -C fortran run
julia-learning:
	cd julia && julia learning_curve_simulation.jl
all: python-generate python-model go-validate rust-summary c-sim cpp-transfer fortran-expertise
clean:
	$(MAKE) -C c clean
	$(MAKE) -C cpp clean
	$(MAKE) -C fortran clean
	rm -f outputs/*.csv outputs/*.txt outputs/*.png
