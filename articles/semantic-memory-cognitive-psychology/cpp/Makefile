CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: category_verification_simulator

category_verification_simulator: category_verification_simulator.cpp
	$(CXX) $(CXXFLAGS) -o category_verification_simulator category_verification_simulator.cpp

run: category_verification_simulator
	./category_verification_simulator ../outputs/cpp_category_verification.csv

clean:
	rm -f category_verification_simulator
