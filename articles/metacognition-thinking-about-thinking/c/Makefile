CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: calibration_simulator

calibration_simulator: calibration_simulator.c
	$(CC) $(CFLAGS) -o calibration_simulator calibration_simulator.c -lm

run: calibration_simulator
	./calibration_simulator 10000

clean:
	rm -f calibration_simulator
