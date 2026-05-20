CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: confirmation_search_simulator

confirmation_search_simulator: confirmation_search_simulator.cpp
	$(CXX) $(CXXFLAGS) -o confirmation_search_simulator confirmation_search_simulator.cpp

run: confirmation_search_simulator
	./confirmation_search_simulator ../outputs/cpp_confirmation_search.csv

clean:
	rm -f confirmation_search_simulator
