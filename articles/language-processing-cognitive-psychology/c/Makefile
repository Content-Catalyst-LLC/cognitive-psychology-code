CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: lexical_access_simulator

lexical_access_simulator: lexical_access_simulator.c
	$(CC) $(CFLAGS) -o lexical_access_simulator lexical_access_simulator.c -lm

run: lexical_access_simulator
	./lexical_access_simulator 10000

clean:
	rm -f lexical_access_simulator
