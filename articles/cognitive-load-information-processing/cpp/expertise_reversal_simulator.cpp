#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Instructional-design and expertise-reversal simulator.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_expertise_reversal.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,expertise_level,condition,prior_knowledge,intrinsic_load,extraneous_load,germane_load,accuracy,effort,mental_efficiency\n";

    int n = 5000;
    double novice_worked = 0.0, novice_problem = 0.0, expert_worked = 0.0, expert_problem = 0.0;
    int nw = 0, np = 0, ew = 0, ep = 0;

    for (int trial = 1; trial <= n; ++trial) {
        bool expert = uniform(rng) < 0.35;
        bool worked = uniform(rng) < 0.50;
        std::string expertise = expert ? "expert" : "novice";
        std::string condition = worked ? "worked_example" : "problem_solving";

        double prior = expert ? 8.0 + noise(rng) : 2.5 + noise(rng);
        if (prior < 0.0) prior = 0.0;
        if (prior > 10.0) prior = 10.0;

        double intrinsic = 6.5 - 0.16 * prior + 0.8 * noise(rng);
        double extraneous = worked ? 2.6 + 0.6 * noise(rng) : 5.6 + 0.8 * noise(rng);
        double germane = worked ? 6.2 + 0.7 * noise(rng) : 4.4 + 0.8 * noise(rng);

        double reversal_penalty = (expert && worked) ? 0.85 : 0.0;
        double latent = -0.8 + 0.42 * prior + 0.32 * germane - 0.42 * intrinsic - 0.55 * extraneous - 0.45 * reversal_penalty + 0.5 * noise(rng);
        double accuracy = logistic(latent);
        double effort = 4.0 + 0.35 * intrinsic + 0.50 * extraneous + 0.18 * germane - 0.22 * prior + 0.6 * noise(rng);
        if (effort < 0.0) effort = 0.0;
        if (effort > 10.0) effort = 10.0;

        double efficiency = (accuracy - effort / 10.0) / std::sqrt(2.0);

        if (!expert && worked) { novice_worked += efficiency; nw++; }
        if (!expert && !worked) { novice_problem += efficiency; np++; }
        if (expert && worked) { expert_worked += efficiency; ew++; }
        if (expert && !worked) { expert_problem += efficiency; ep++; }

        out << trial << "," << expertise << "," << condition << "," << prior << "," << intrinsic << ","
            << extraneous << "," << germane << "," << accuracy << "," << effort << "," << efficiency << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Novice worked-example efficiency: " << novice_worked / nw << "\n";
    std::cout << "Novice problem-solving efficiency: " << novice_problem / np << "\n";
    std::cout << "Expert worked-example efficiency: " << expert_worked / ew << "\n";
    std::cout << "Expert problem-solving efficiency: " << expert_problem / ep << "\n";
    return 0;
}
