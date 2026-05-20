CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: utility_satisficing_simulator

utility_satisficing_simulator: utility_satisficing_simulator.c
	$(CC) $(CFLAGS) -o utility_satisficing_simulator utility_satisficing_simulator.c -lm

run: utility_satisficing_simulator
	./utility_satisficing_simulator 10000

clean:
	rm -f utility_satisficing_simulator
