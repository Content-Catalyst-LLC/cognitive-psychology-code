FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: risk_sensitivity_model

risk_sensitivity_model: risk_sensitivity_model.f90
	$(FC) $(FFLAGS) -o risk_sensitivity_model risk_sensitivity_model.f90

run: risk_sensitivity_model
	./risk_sensitivity_model

clean:
	rm -f risk_sensitivity_model
