CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: causal_intervention_simulator

causal_intervention_simulator: causal_intervention_simulator.cpp
	$(CXX) $(CXXFLAGS) -o causal_intervention_simulator causal_intervention_simulator.cpp

run: causal_intervention_simulator
	./causal_intervention_simulator ../outputs/cpp_causal_interventions.csv

clean:
	rm -f causal_intervention_simulator
