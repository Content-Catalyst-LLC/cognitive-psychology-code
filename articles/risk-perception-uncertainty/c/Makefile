CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: risk_weighting_simulator

risk_weighting_simulator: risk_weighting_simulator.c
	$(CC) $(CFLAGS) -o risk_weighting_simulator risk_weighting_simulator.c -lm

run: risk_weighting_simulator
	./risk_weighting_simulator 10000

clean:
	rm -f risk_weighting_simulator
