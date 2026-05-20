CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: strategy_selection_simulator

strategy_selection_simulator: strategy_selection_simulator.cpp
	$(CXX) $(CXXFLAGS) -o strategy_selection_simulator strategy_selection_simulator.cpp

run: strategy_selection_simulator
	./strategy_selection_simulator ../outputs/cpp_strategy_selection.csv

clean:
	rm -f strategy_selection_simulator
