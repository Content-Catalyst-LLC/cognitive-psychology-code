FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: modality_persistence_model

modality_persistence_model: modality_persistence_model.f90
	$(FC) $(FFLAGS) -o modality_persistence_model modality_persistence_model.f90

run: modality_persistence_model
	./modality_persistence_model

clean:
	rm -f modality_persistence_model
