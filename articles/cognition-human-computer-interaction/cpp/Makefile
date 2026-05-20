CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: fitts_decision_simulator

fitts_decision_simulator: fitts_decision_simulator.cpp
	$(CXX) $(CXXFLAGS) -o fitts_decision_simulator fitts_decision_simulator.cpp

run: fitts_decision_simulator
	./fitts_decision_simulator ../outputs/cpp_fitts_decision_summary.csv

clean:
	rm -f fitts_decision_simulator
