CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17
all: deliberate_practice_transfer_simulator
deliberate_practice_transfer_simulator: deliberate_practice_transfer_simulator.cpp
	$(CXX) $(CXXFLAGS) -o deliberate_practice_transfer_simulator deliberate_practice_transfer_simulator.cpp
run: deliberate_practice_transfer_simulator
	./deliberate_practice_transfer_simulator ../outputs/cpp_deliberate_practice_transfer.csv
clean:
	rm -f deliberate_practice_transfer_simulator
