FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: retention_interference_model

retention_interference_model: retention_interference_model.f90
	$(FC) $(FFLAGS) -o retention_interference_model retention_interference_model.f90

run: retention_interference_model
	./retention_interference_model

clean:
	rm -f retention_interference_model
