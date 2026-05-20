#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Updating and interference simulator for working-memory tasks.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_updating_interference.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,load,updating_demand,interference,attentional_control,update_gate,accuracy,rt_ms,correct\n";

    int n = 5000;
    int correct_sum = 0;
    double rt_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        int load = 1 + (int)(10.0 * uniform(rng));
        double updating = 10.0 * uniform(rng);
        double interference = 10.0 * uniform(rng);
        double control = std::max(0.0, std::min(10.0, 6.0 + noise(rng)));
        double gate = std::max(0.0, std::min(1.0, 0.55 + 0.08 * control - 0.06 * interference + 0.10 * noise(rng)));
        double accuracy = logistic(2.1 - 0.42 * load - 0.25 * updating - 0.22 * interference + 0.18 * control + 0.65 * gate);
        int correct = uniform(rng) < accuracy ? 1 : 0;
        double rt_ms = std::exp(std::log(950.0) + 0.045 * load + 0.050 * updating + 0.045 * interference - 0.025 * control + 0.12 * noise(rng));

        correct_sum += correct;
        rt_sum += rt_ms;

        out << trial << "," << load << "," << updating << "," << interference << "," << control
            << "," << gate << "," << accuracy << "," << rt_ms << "," << correct << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Correct rate: " << (double)correct_sum / n << "\n";
    std::cout << "Mean RT ms: " << rt_sum / n << "\n";
    return 0;
}
