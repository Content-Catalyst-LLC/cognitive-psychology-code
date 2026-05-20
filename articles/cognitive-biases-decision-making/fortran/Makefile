FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: calibration_overconfidence_model

calibration_overconfidence_model: calibration_overconfidence_model.f90
	$(FC) $(FFLAGS) -o calibration_overconfidence_model calibration_overconfidence_model.f90

run: calibration_overconfidence_model
	./calibration_overconfidence_model

clean:
	rm -f calibration_overconfidence_model
