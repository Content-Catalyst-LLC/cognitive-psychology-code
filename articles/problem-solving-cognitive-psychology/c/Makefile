CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: means_end_search_simulator

means_end_search_simulator: means_end_search_simulator.c
	$(CC) $(CFLAGS) -o means_end_search_simulator means_end_search_simulator.c -lm

run: means_end_search_simulator
	./means_end_search_simulator 10000

clean:
	rm -f means_end_search_simulator
