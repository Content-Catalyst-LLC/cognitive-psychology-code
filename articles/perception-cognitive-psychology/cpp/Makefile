CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: visual_search_simulator

visual_search_simulator: visual_search_simulator.cpp
	$(CXX) $(CXXFLAGS) -o visual_search_simulator visual_search_simulator.cpp

run: visual_search_simulator
	./visual_search_simulator ../outputs/cpp_visual_search.csv

clean:
	rm -f visual_search_simulator
