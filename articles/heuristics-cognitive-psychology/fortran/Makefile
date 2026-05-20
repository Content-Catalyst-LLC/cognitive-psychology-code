FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: effort_accuracy_model

effort_accuracy_model: effort_accuracy_model.f90
	$(FC) $(FFLAGS) -o effort_accuracy_model effort_accuracy_model.f90

run: effort_accuracy_model
	./effort_accuracy_model

clean:
	rm -f effort_accuracy_model
