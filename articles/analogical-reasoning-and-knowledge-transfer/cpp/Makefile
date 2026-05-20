CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: source_retrieval_simulator

source_retrieval_simulator: source_retrieval_simulator.cpp
	$(CXX) $(CXXFLAGS) -o source_retrieval_simulator source_retrieval_simulator.cpp

run: source_retrieval_simulator
	./source_retrieval_simulator ../outputs/cpp_source_retrieval.csv

clean:
	rm -f source_retrieval_simulator
