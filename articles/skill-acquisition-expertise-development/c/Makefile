CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11
all: error_decay_simulator
error_decay_simulator: error_decay_simulator.c
	$(CC) $(CFLAGS) -o error_decay_simulator error_decay_simulator.c -lm
run: error_decay_simulator
	./error_decay_simulator 10000
clean:
	rm -f error_decay_simulator
