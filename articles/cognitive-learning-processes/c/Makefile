CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: learning_curve_simulator

learning_curve_simulator: learning_curve_simulator.c
	$(CC) $(CFLAGS) -o learning_curve_simulator learning_curve_simulator.c -lm

run: learning_curve_simulator
	./learning_curve_simulator 10000

clean:
	rm -f learning_curve_simulator
