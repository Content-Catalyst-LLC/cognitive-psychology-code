FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: category_discrimination_model

category_discrimination_model: category_discrimination_model.f90
	$(FC) $(FFLAGS) -o category_discrimination_model category_discrimination_model.f90

run: category_discrimination_model
	./category_discrimination_model

clean:
	rm -f category_discrimination_model
