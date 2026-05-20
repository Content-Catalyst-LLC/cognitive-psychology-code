CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: misinformation_source_simulator

misinformation_source_simulator: misinformation_source_simulator.cpp
	$(CXX) $(CXXFLAGS) -o misinformation_source_simulator misinformation_source_simulator.cpp

run: misinformation_source_simulator
	./misinformation_source_simulator ../outputs/cpp_misinformation_source.csv

clean:
	rm -f misinformation_source_simulator
