CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: iconic_decay_simulator

iconic_decay_simulator: iconic_decay_simulator.c
	$(CC) $(CFLAGS) -o iconic_decay_simulator iconic_decay_simulator.c -lm

run: iconic_decay_simulator
	./iconic_decay_simulator 10000

clean:
	rm -f iconic_decay_simulator
