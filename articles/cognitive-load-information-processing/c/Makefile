CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: overload_simulator

overload_simulator: overload_simulator.c
	$(CC) $(CFLAGS) -o overload_simulator overload_simulator.c -lm

run: overload_simulator
	./overload_simulator 10000

clean:
	rm -f overload_simulator
