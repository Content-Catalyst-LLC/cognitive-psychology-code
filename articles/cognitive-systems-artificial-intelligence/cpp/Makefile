CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: production_system_simulator

production_system_simulator: production_system_simulator.cpp
	$(CXX) $(CXXFLAGS) -o production_system_simulator production_system_simulator.cpp

run: production_system_simulator
	./production_system_simulator ../outputs/cpp_production_system_summary.csv

clean:
	rm -f production_system_simulator
