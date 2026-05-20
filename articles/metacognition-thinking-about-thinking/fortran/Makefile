FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: metacognitive_sensitivity_model

metacognitive_sensitivity_model: metacognitive_sensitivity_model.f90
	$(FC) $(FFLAGS) -o metacognitive_sensitivity_model metacognitive_sensitivity_model.f90

run: metacognitive_sensitivity_model
	./metacognitive_sensitivity_model

clean:
	rm -f metacognitive_sensitivity_model
