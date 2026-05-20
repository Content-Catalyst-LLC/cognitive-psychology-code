CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: memory_capacity_simulator

memory_capacity_simulator: memory_capacity_simulator.c
	$(CC) $(CFLAGS) -o memory_capacity_simulator memory_capacity_simulator.c -lm

run: memory_capacity_simulator
	./memory_capacity_simulator 10000

clean:
	rm -f memory_capacity_simulator
