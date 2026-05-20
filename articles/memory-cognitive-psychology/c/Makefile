CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: forgetting_simulator

forgetting_simulator: forgetting_simulator.c
	$(CC) $(CFLAGS) -o forgetting_simulator forgetting_simulator.c -lm

run: forgetting_simulator
	./forgetting_simulator 10000

clean:
	rm -f forgetting_simulator
