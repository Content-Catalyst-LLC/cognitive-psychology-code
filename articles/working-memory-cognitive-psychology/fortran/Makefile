FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: load_accuracy_model

load_accuracy_model: load_accuracy_model.f90
	$(FC) $(FFLAGS) -o load_accuracy_model load_accuracy_model.f90

run: load_accuracy_model
	./load_accuracy_model

clean:
	rm -f load_accuracy_model
