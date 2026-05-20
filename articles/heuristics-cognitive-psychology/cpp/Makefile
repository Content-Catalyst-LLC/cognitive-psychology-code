CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: adaptive_strategy_simulator

adaptive_strategy_simulator: adaptive_strategy_simulator.cpp
	$(CXX) $(CXXFLAGS) -o adaptive_strategy_simulator adaptive_strategy_simulator.cpp

run: adaptive_strategy_simulator
	./adaptive_strategy_simulator ../outputs/cpp_adaptive_strategy.csv

clean:
	rm -f adaptive_strategy_simulator
