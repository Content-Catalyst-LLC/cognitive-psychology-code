CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

all: framing_loss_aversion_simulator

framing_loss_aversion_simulator: framing_loss_aversion_simulator.c
	$(CC) $(CFLAGS) -o framing_loss_aversion_simulator framing_loss_aversion_simulator.c -lm

run: framing_loss_aversion_simulator
	./framing_loss_aversion_simulator 10000

clean:
	rm -f framing_loss_aversion_simulator
