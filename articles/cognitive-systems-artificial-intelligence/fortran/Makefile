FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: calibration_signal_model

calibration_signal_model: calibration_signal_model.f90
	$(FC) $(FFLAGS) -o calibration_signal_model calibration_signal_model.f90

run: calibration_signal_model
	./calibration_signal_model

clean:
	rm -f calibration_signal_model
