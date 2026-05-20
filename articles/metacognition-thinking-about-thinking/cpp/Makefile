CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: study_allocation_simulator

study_allocation_simulator: study_allocation_simulator.cpp
	$(CXX) $(CXXFLAGS) -o study_allocation_simulator study_allocation_simulator.cpp

run: study_allocation_simulator
	./study_allocation_simulator ../outputs/cpp_study_allocation.csv

clean:
	rm -f study_allocation_simulator
