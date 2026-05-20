#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Social amplification and risk-communication simulation.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_social_amplification.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,communication_condition,base_probability,signal_strength,trust,ambiguity,affect,perceived_risk,protective_action_probability\n";

    int n = 5000;
    double risk_sum = 0.0;
    double action_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool narrative = uniform(rng) < 0.40;
        bool uncertainty_explicit = uniform(rng) < 0.40;
        std::string condition = narrative ? "narrative" : (uncertainty_explicit ? "uncertainty_explicit" : "numeric_only");

        double base_probability = 0.01 + 0.35 * uniform(rng);
        double signal_strength = narrative ? 7.0 + 2.0 * uniform(rng) : 3.0 + 4.0 * uniform(rng);
        double trust = uncertainty_explicit ? 5.8 + 1.4 * uniform(rng) : 4.2 + 2.2 * uniform(rng);
        double ambiguity = uncertainty_explicit ? 6.0 + 2.0 * uniform(rng) : 3.0 + 4.0 * uniform(rng);
        double affect = 2.0 + 0.8 * signal_strength + 0.6 * narrative + 0.7 * noise(rng);
        if (affect < 0.0) affect = 0.0;
        if (affect > 10.0) affect = 10.0;

        double perceived_risk = 1.0 + 7.0 * base_probability + 0.55 * signal_strength + 0.35 * affect + 0.22 * ambiguity - 0.16 * trust + 0.6 * noise(rng);
        if (perceived_risk < 0.0) perceived_risk = 0.0;
        if (perceived_risk > 10.0) perceived_risk = 10.0;

        double action_p = logistic(-2.4 + 0.38 * perceived_risk + 0.16 * trust - 0.12 * ambiguity + 0.10 * uncertainty_explicit);

        risk_sum += perceived_risk;
        action_sum += action_p;

        out << trial << "," << condition << "," << base_probability << "," << signal_strength << ","
            << trust << "," << ambiguity << "," << affect << "," << perceived_risk << "," << action_p << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean perceived risk: " << risk_sum / n << "\n";
    std::cout << "Mean protective-action probability: " << action_sum / n << "\n";
    return 0;
}
