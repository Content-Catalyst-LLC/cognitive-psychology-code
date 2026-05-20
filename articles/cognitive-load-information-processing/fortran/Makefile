FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: workload_threshold_model

workload_threshold_model: workload_threshold_model.f90
	$(FC) $(FFLAGS) -o workload_threshold_model workload_threshold_model.f90

run: workload_threshold_model
	./workload_threshold_model

clean:
	rm -f workload_threshold_model
