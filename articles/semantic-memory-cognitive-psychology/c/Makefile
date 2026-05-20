CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: spreading_activation_simulator

spreading_activation_simulator: spreading_activation_simulator.c
	$(CC) $(CFLAGS) -o spreading_activation_simulator spreading_activation_simulator.c -lm

run: spreading_activation_simulator
	./spreading_activation_simulator 10000

clean:
	rm -f spreading_activation_simulator
