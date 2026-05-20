CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: interaction_cost_simulator

interaction_cost_simulator: interaction_cost_simulator.c
	$(CC) $(CFLAGS) -o interaction_cost_simulator interaction_cost_simulator.c -lm

run: interaction_cost_simulator
	./interaction_cost_simulator 10000

clean:
	rm -f interaction_cost_simulator
