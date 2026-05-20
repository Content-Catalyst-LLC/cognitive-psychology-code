CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: relational_fit_simulator

relational_fit_simulator: relational_fit_simulator.c
	$(CC) $(CFLAGS) -o relational_fit_simulator relational_fit_simulator.c -lm

run: relational_fit_simulator
	./relational_fit_simulator 10000

clean:
	rm -f relational_fit_simulator
