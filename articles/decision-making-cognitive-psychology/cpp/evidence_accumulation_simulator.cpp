#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Evidence-accumulation simulator for two-choice decision tasks.
 */

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_evidence_accumulation.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::normal_distribution<double> noise(0.0, 1.0);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,evidence_strength,threshold,time_pressure,uncertainty,drift,choice,rt_steps,correct\n";

    int n = 5000;
    int correct_sum = 0;
    double rt_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        double evidence = std::max(-3.0, std::min(3.0, noise(rng)));
        double time_pressure = 10.0 * uniform(rng);
        double uncertainty = 10.0 * uniform(rng);
        double threshold = std::max(0.45, std::min(2.5, 1.2 + 0.08 * uncertainty - 0.06 * time_pressure));
        double drift = 0.32 * evidence - 0.04 * uncertainty;

        double x = 0.0;
        int choice = 0;
        int steps = 0;
        for (steps = 1; steps <= 5000; ++steps) {
            x += drift * 0.01 + std::sqrt(0.01) * noise(rng);
            if (x >= threshold) { choice = 1; break; }
            if (x <= -threshold) { choice = 0; break; }
        }

        if (steps > 5000) {
            choice = x >= 0.0 ? 1 : 0;
            steps = 5000;
        }

        int criterion = evidence >= 0.0 ? 1 : 0;
        int correct = choice == criterion ? 1 : 0;
        correct_sum += correct;
        rt_sum += steps;

        out << trial << "," << evidence << "," << threshold << "," << time_pressure << "," << uncertainty
            << "," << drift << "," << choice << "," << steps << "," << correct << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Accuracy: " << (double)correct_sum / n << "\n";
    std::cout << "Mean response-time steps: " << rt_sum / n << "\n";
    return 0;
}
