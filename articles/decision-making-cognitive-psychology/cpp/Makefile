CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: evidence_accumulation_simulator

evidence_accumulation_simulator: evidence_accumulation_simulator.cpp
	$(CXX) $(CXXFLAGS) -o evidence_accumulation_simulator evidence_accumulation_simulator.cpp

run: evidence_accumulation_simulator
	./evidence_accumulation_simulator ../outputs/cpp_evidence_accumulation.csv

clean:
	rm -f evidence_accumulation_simulator
