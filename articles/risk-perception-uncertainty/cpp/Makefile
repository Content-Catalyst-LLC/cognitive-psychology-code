CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: social_amplification_simulator

social_amplification_simulator: social_amplification_simulator.cpp
	$(CXX) $(CXXFLAGS) -o social_amplification_simulator social_amplification_simulator.cpp

run: social_amplification_simulator
	./social_amplification_simulator ../outputs/cpp_social_amplification.csv

clean:
	rm -f social_amplification_simulator
