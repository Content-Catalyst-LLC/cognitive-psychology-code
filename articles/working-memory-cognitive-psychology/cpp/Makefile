CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: updating_interference_simulator

updating_interference_simulator: updating_interference_simulator.cpp
	$(CXX) $(CXXFLAGS) -o updating_interference_simulator updating_interference_simulator.cpp

run: updating_interference_simulator
	./updating_interference_simulator ../outputs/cpp_updating_interference.csv

clean:
	rm -f updating_interference_simulator
