CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: anchoring_simulator

anchoring_simulator: anchoring_simulator.c
	$(CC) $(CFLAGS) -o anchoring_simulator anchoring_simulator.c -lm

run: anchoring_simulator
	./anchoring_simulator 10000

clean:
	rm -f anchoring_simulator
