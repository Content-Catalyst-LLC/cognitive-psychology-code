FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: warning_detection_model

warning_detection_model: warning_detection_model.f90
	$(FC) $(FFLAGS) -o warning_detection_model warning_detection_model.f90

run: warning_detection_model
	./warning_detection_model

clean:
	rm -f warning_detection_model
