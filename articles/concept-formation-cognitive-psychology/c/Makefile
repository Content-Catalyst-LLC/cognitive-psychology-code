CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: prototype_categorization_simulator

prototype_categorization_simulator: prototype_categorization_simulator.c
	$(CC) $(CFLAGS) -o prototype_categorization_simulator prototype_categorization_simulator.c -lm

run: prototype_categorization_simulator
	./prototype_categorization_simulator 10000

clean:
	rm -f prototype_categorization_simulator
