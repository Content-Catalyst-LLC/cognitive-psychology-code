FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: learning_sensitivity_model

learning_sensitivity_model: learning_sensitivity_model.f90
	$(FC) $(FFLAGS) -o learning_sensitivity_model learning_sensitivity_model.f90

run: learning_sensitivity_model
	./learning_sensitivity_model

clean:
	rm -f learning_sensitivity_model
