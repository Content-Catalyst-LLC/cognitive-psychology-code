#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Confirmation-bias evidence-search simulator.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_confirmation_search.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,prior_belief,confirming_selected,disconfirming_selected,confirmation_index,accuracy,decision_quality\n";

    int n = 5000;
    double control_index = 0.0;
    double intervention_index = 0.0;
    int control_n = 0;
    int intervention_n = 0;

    for (int trial = 1; trial <= n; ++trial) {
        bool intervention = uniform(rng) < 0.5;
        std::string condition = intervention ? "consider_opposite" : "control";

        double prior = uniform(rng);
        double confirm_tendency = intervention ? 0.10 : 0.36;
        double disconfirm_tendency = intervention ? 0.34 : 0.16;

        int confirming = 0;
        int disconfirming = 0;
        for (int cue = 0; cue < 8; ++cue) {
            if (uniform(rng) < 0.35 + confirm_tendency + 0.20 * prior) confirming++;
            if (uniform(rng) < 0.25 + disconfirm_tendency + 0.10 * (1.0 - prior)) disconfirming++;
        }

        double confirmation_index = (confirming - disconfirming) / 8.0;
        double accuracy = logistic(-0.2 + 0.28 * disconfirming + 0.18 * confirming - 0.35 * confirmation_index + 0.2 * noise(rng));
        double quality = 0.35 + 0.45 * accuracy - 0.20 * std::fabs(confirmation_index) + (intervention ? 0.08 : 0.0);

        if (quality < 0.0) quality = 0.0;
        if (quality > 1.0) quality = 1.0;

        if (intervention) {
            intervention_index += confirmation_index;
            intervention_n++;
        } else {
            control_index += confirmation_index;
            control_n++;
        }

        out << trial << "," << condition << "," << prior << "," << confirming << "," << disconfirming
            << "," << confirmation_index << "," << accuracy << "," << quality << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean control confirmation index: " << control_index / control_n << "\n";
    std::cout << "Mean intervention confirmation index: " << intervention_index / intervention_n << "\n";
    return 0;
}
