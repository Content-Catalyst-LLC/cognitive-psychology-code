FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: progress_monitoring_model

progress_monitoring_model: progress_monitoring_model.f90
	$(FC) $(FFLAGS) -o progress_monitoring_model progress_monitoring_model.f90

run: progress_monitoring_model
	./progress_monitoring_model

clean:
	rm -f progress_monitoring_model
