FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: semantic_verification_model

semantic_verification_model: semantic_verification_model.f90
	$(FC) $(FFLAGS) -o semantic_verification_model semantic_verification_model.f90

run: semantic_verification_model
	./semantic_verification_model

clean:
	rm -f semantic_verification_model
