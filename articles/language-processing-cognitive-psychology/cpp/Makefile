CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: sentence_processing_simulator

sentence_processing_simulator: sentence_processing_simulator.cpp
	$(CXX) $(CXXFLAGS) -o sentence_processing_simulator sentence_processing_simulator.cpp

run: sentence_processing_simulator
	./sentence_processing_simulator ../outputs/cpp_sentence_processing.csv

clean:
	rm -f sentence_processing_simulator
