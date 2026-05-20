FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: relational_match_detection_model

relational_match_detection_model: relational_match_detection_model.f90
	$(FC) $(FFLAGS) -o relational_match_detection_model relational_match_detection_model.f90

run: relational_match_detection_model
	./relational_match_detection_model

clean:
	rm -f relational_match_detection_model
