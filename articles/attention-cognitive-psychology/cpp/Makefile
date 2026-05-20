CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: attentional_priority_simulator

attentional_priority_simulator: attentional_priority_simulator.cpp
	$(CXX) $(CXXFLAGS) -o attentional_priority_simulator attentional_priority_simulator.cpp

run: attentional_priority_simulator
	./attentional_priority_simulator ../outputs/cpp_attentional_priority.csv

clean:
	rm -f attentional_priority_simulator
