CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: partial_report_selection_simulator

partial_report_selection_simulator: partial_report_selection_simulator.cpp
	$(CXX) $(CXXFLAGS) -o partial_report_selection_simulator partial_report_selection_simulator.cpp

run: partial_report_selection_simulator
	./partial_report_selection_simulator ../outputs/cpp_partial_report_selection.csv

clean:
	rm -f partial_report_selection_simulator
