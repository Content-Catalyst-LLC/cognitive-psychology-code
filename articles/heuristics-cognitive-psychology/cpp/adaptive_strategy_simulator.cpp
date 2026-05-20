#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <numeric>
#include <random>
#include <string>
#include <vector>

/*
 * Adaptive strategy-selection simulator.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_adaptive_strategy.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,environment_predictability,information_cost,time_pressure,strategy,cue_count,accuracy,effort,adaptive_utility\n";

    int n = 5000;
    double heuristic_utility_sum = 0.0;
    double analytic_utility_sum = 0.0;
    int heuristic_n = 0;
    int analytic_n = 0;

    for (int trial = 1; trial <= n; ++trial) {
        double predictability = uniform(rng);
        double information_cost = 10.0 * uniform(rng);
        double time_pressure = 10.0 * uniform(rng);

        bool choose_heuristic = (information_cost + time_pressure > 8.5) || (predictability < 0.45);
        std::string strategy = choose_heuristic ? "heuristic" : "analytic";

        int cue_count = choose_heuristic ? 1 + (int)(3.0 * uniform(rng)) : 5 + (int)(5.0 * uniform(rng));
        double effort = choose_heuristic ? 2.8 + 0.35 * cue_count + 0.7 * noise(rng) : 5.4 + 0.45 * cue_count + 0.8 * noise(rng);
        if (effort < 0.0) effort = 0.0;
        if (effort > 10.0) effort = 10.0;

        double accuracy;
        if (choose_heuristic) {
            accuracy = logistic(-0.4 + 1.8 * predictability + 0.20 * cue_count - 0.06 * information_cost + 0.4 * noise(rng));
        } else {
            accuracy = logistic(-0.6 + 2.3 * predictability + 0.15 * cue_count - 0.05 * time_pressure + 0.35 * noise(rng));
        }

        double utility = accuracy - 0.12 * effort - 0.03 * information_cost - 0.02 * time_pressure;

        if (choose_heuristic) {
            heuristic_utility_sum += utility;
            heuristic_n++;
        } else {
            analytic_utility_sum += utility;
            analytic_n++;
        }

        out << trial << "," << predictability << "," << information_cost << "," << time_pressure << ","
            << strategy << "," << cue_count << "," << accuracy << "," << effort << "," << utility << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean heuristic utility: " << heuristic_utility_sum / heuristic_n << "\n";
    std::cout << "Mean analytic utility: " << analytic_utility_sum / analytic_n << "\n";
    return 0;
}
