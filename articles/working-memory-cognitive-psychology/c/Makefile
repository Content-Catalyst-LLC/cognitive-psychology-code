CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: span_capacity_simulator

span_capacity_simulator: span_capacity_simulator.c
	$(CC) $(CFLAGS) -o span_capacity_simulator span_capacity_simulator.c -lm

run: span_capacity_simulator
	./span_capacity_simulator 10000

clean:
	rm -f span_capacity_simulator
