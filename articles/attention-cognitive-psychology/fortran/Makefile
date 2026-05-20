FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: signal_detection_lapse_model

signal_detection_lapse_model: signal_detection_lapse_model.f90
	$(FC) $(FFLAGS) -o signal_detection_lapse_model signal_detection_lapse_model.f90

run: signal_detection_lapse_model
	./signal_detection_lapse_model

clean:
	rm -f signal_detection_lapse_model
