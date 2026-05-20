FC ?= gfortran
FFLAGS ?= -O2 -Wall

all: model_quality_detection

model_quality_detection: model_quality_detection.f90
	$(FC) $(FFLAGS) -o model_quality_detection model_quality_detection.f90

run: model_quality_detection
	./model_quality_detection

clean:
	rm -f model_quality_detection
