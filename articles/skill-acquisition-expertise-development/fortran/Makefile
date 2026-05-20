FC ?= gfortran
FFLAGS ?= -O2 -Wall
all: expertise_sensitivity_model
expertise_sensitivity_model: expertise_sensitivity_model.f90
	$(FC) $(FFLAGS) -o expertise_sensitivity_model expertise_sensitivity_model.f90
run: expertise_sensitivity_model
	./expertise_sensitivity_model
clean:
	rm -f expertise_sensitivity_model
