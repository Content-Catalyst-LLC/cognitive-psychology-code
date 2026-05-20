CXX ?= c++
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++17

all: drift_diffusion_decision

drift_diffusion_decision: drift_diffusion_decision.cpp
	$(CXX) $(CXXFLAGS) -o drift_diffusion_decision drift_diffusion_decision.cpp

run: drift_diffusion_decision
	./drift_diffusion_decision ../outputs/cpp_ddm_summary.csv

clean:
	rm -f drift_diffusion_decision
