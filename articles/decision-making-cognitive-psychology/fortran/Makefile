FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: threshold_rt_model

threshold_rt_model: threshold_rt_model.f90
	$(FC) $(FFLAGS) -o threshold_rt_model threshold_rt_model.f90

run: threshold_rt_model
	./threshold_rt_model

clean:
	rm -f threshold_rt_model
