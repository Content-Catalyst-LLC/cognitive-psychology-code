CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: prospect_value_simulator

prospect_value_simulator: prospect_value_simulator.c
	$(CC) $(CFLAGS) -o prospect_value_simulator prospect_value_simulator.c -lm

run: prospect_value_simulator
	./prospect_value_simulator 10000

clean:
	rm -f prospect_value_simulator
