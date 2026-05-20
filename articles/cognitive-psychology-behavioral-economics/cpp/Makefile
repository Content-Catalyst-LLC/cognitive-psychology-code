CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: choice_architecture_simulator

choice_architecture_simulator: choice_architecture_simulator.cpp
	$(CXX) $(CXXFLAGS) -o choice_architecture_simulator choice_architecture_simulator.cpp

run: choice_architecture_simulator
	./choice_architecture_simulator ../outputs/cpp_choice_architecture_summary.csv

clean:
	rm -f choice_architecture_simulator
