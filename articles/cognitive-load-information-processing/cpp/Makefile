CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: expertise_reversal_simulator

expertise_reversal_simulator: expertise_reversal_simulator.cpp
	$(CXX) $(CXXFLAGS) -o expertise_reversal_simulator expertise_reversal_simulator.cpp

run: expertise_reversal_simulator
	./expertise_reversal_simulator ../outputs/cpp_expertise_reversal.csv

clean:
	rm -f expertise_reversal_simulator
