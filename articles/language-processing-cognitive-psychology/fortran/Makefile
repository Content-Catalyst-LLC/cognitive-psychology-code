FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: comprehension_detection_model

comprehension_detection_model: comprehension_detection_model.f90
	$(FC) $(FFLAGS) -o comprehension_detection_model comprehension_detection_model.f90

run: comprehension_detection_model
	./comprehension_detection_model

clean:
	rm -f comprehension_detection_model
