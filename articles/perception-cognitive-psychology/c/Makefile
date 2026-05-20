CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: psychometric_threshold_simulator

psychometric_threshold_simulator: psychometric_threshold_simulator.c
	$(CC) $(CFLAGS) -o psychometric_threshold_simulator psychometric_threshold_simulator.c -lm

run: psychometric_threshold_simulator
	./psychometric_threshold_simulator 10000

clean:
	rm -f psychometric_threshold_simulator
