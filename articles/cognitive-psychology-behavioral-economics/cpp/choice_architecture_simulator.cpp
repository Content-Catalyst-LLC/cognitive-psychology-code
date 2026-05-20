#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Choice-architecture simulation.
 *
 * Models how defaults, framing, social norms, and cognitive load can shape
 * uptake of a target choice. This is a teaching/research scaffold, not a
 * causal estimate from real data.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_choice_architecture_summary.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,default_present,loss_frame,social_norm,cognitive_load,choice_probability,choice\n";

    int n = 5000;
    int choice_count = 0;
    double probability_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool default_present = uniform(rng) < 0.45;
        bool loss_frame = uniform(rng) < 0.40;
        double social_norm = 10.0 * uniform(rng);
        double cognitive_load = 10.0 * uniform(rng);

        std::string condition = default_present ? "default_nudge" : (loss_frame ? "loss_frame" : "control");

        double p = logistic(
            -1.25
            + 1.55 * default_present
            + 0.55 * loss_frame
            + 0.18 * social_norm
            + 0.08 * cognitive_load
            + 0.20 * noise(rng)
        );

        int choice = uniform(rng) < p ? 1 : 0;
        choice_count += choice;
        probability_sum += p;

        out << trial << ","
            << condition << ","
            << default_present << ","
            << loss_frame << ","
            << social_norm << ","
            << cognitive_load << ","
            << p << ","
            << choice << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Choice rate: " << static_cast<double>(choice_count) / n << "\n";
    std::cout << "Mean choice probability: " << probability_sum / n << "\n";

    return 0;
}
