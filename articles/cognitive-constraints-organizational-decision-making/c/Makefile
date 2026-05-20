CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: cognitive_burden_simulator

cognitive_burden_simulator: cognitive_burden_simulator.c
	$(CC) $(CFLAGS) -o cognitive_burden_simulator cognitive_burden_simulator.c -lm

run: cognitive_burden_simulator
	./cognitive_burden_simulator 10000

clean:
	rm -f cognitive_burden_simulator
