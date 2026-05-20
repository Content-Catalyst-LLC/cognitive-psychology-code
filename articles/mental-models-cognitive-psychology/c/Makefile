CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: prediction_error_simulator

prediction_error_simulator: prediction_error_simulator.c
	$(CC) $(CFLAGS) -o prediction_error_simulator prediction_error_simulator.c -lm

run: prediction_error_simulator
	./prediction_error_simulator 10000

clean:
	rm -f prediction_error_simulator
