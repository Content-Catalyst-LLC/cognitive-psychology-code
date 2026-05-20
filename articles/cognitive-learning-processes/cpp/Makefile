CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: retrieval_transfer_simulator

retrieval_transfer_simulator: retrieval_transfer_simulator.cpp
	$(CXX) $(CXXFLAGS) -o retrieval_transfer_simulator retrieval_transfer_simulator.cpp

run: retrieval_transfer_simulator
	./retrieval_transfer_simulator ../outputs/cpp_retrieval_transfer.csv

clean:
	rm -f retrieval_transfer_simulator
