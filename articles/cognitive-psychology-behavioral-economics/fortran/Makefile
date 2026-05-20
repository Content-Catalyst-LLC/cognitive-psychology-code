FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: risk_perception_model

risk_perception_model: risk_perception_model.f90
	$(FC) $(FFLAGS) -o risk_perception_model risk_perception_model.f90

run: risk_perception_model
	./risk_perception_model

clean:
	rm -f risk_perception_model
