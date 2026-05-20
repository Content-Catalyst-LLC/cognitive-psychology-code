CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: vigilance_simulator

vigilance_simulator: vigilance_simulator.c
	$(CC) $(CFLAGS) -o vigilance_simulator vigilance_simulator.c -lm

run: vigilance_simulator
	./vigilance_simulator 10000

clean:
	rm -f vigilance_simulator
