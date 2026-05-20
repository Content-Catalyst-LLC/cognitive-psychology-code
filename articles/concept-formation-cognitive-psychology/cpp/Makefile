CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: exemplar_boundary_simulator

exemplar_boundary_simulator: exemplar_boundary_simulator.cpp
	$(CXX) $(CXXFLAGS) -o exemplar_boundary_simulator exemplar_boundary_simulator.cpp

run: exemplar_boundary_simulator
	./exemplar_boundary_simulator ../outputs/cpp_exemplar_boundary.csv

clean:
	rm -f exemplar_boundary_simulator
