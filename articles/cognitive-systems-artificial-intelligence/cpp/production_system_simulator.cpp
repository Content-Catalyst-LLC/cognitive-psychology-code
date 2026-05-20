#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>

/*
 * Production-system style simulation for cognitive AI systems.
 *
 * The model treats candidate productions/actions as having:
 * - expected value
 * - retrieval cost
 * - uncertainty penalty
 * - explanation support
 *
 * A softmax decision rule selects an action. The simulation records whether
 * the selected production matches the highest true-value production.
 */

struct Production {
    double true_value;
    double estimated_value;
    double retrieval_cost;
    double explanation_support;
};

double softmax_sample(std::mt19937 &rng, const std::vector<double> &utilities) {
    double max_u = *std::max_element(utilities.begin(), utilities.end());
    std::vector<double> weights;
    weights.reserve(utilities.size());

    double sum = 0.0;
    for (double u : utilities) {
        double w = std::exp(u - max_u);
        weights.push_back(w);
        sum += w;
    }

    std::uniform_real_distribution<double> uniform(0.0, sum);
    double threshold = uniform(rng);
    double cumulative = 0.0;

    for (size_t i = 0; i < weights.size(); ++i) {
        cumulative += weights[i];
        if (threshold <= cumulative) {
            return static_cast<double>(i);
        }
    }

    return static_cast<double>(weights.size() - 1);
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_production_system_summary.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::normal_distribution<double> noise(0.0, 1.0);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,n_productions,uncertainty,chosen_index,best_index,success,explanation_support,utility_gap\n";

    int n = 5000;
    int success_count = 0;
    double explanation_sum = 0.0;
    double gap_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool high_uncertainty = uniform(rng) < 0.45;
        std::string condition = high_uncertainty ? "high_uncertainty" : "baseline";
        int n_productions = high_uncertainty ? 8 : 5;
        double uncertainty = high_uncertainty ? 7.0 + noise(rng) : 3.5 + noise(rng);

        std::vector<Production> productions;
        std::vector<double> utilities;

        for (int i = 0; i < n_productions; ++i) {
            double true_value = 3.0 + noise(rng);
            double retrieval_cost = 0.5 + 2.0 * uniform(rng);
            double explanation_support = 2.0 + 8.0 * uniform(rng);
            double estimated_value = true_value + noise(rng) * uncertainty / 5.0;

            double utility =
                1.3 * estimated_value
                - 0.45 * retrieval_cost
                - 0.18 * uncertainty
                + 0.12 * explanation_support;

            productions.push_back({true_value, estimated_value, retrieval_cost, explanation_support});
            utilities.push_back(utility);
        }

        int chosen = static_cast<int>(softmax_sample(rng, utilities));

        int best = 0;
        for (int i = 1; i < n_productions; ++i) {
            if (productions[i].true_value > productions[best].true_value) {
                best = i;
            }
        }

        int success = chosen == best ? 1 : 0;
        success_count += success;

        double best_value = productions[best].true_value;
        double chosen_value = productions[chosen].true_value;
        double gap = best_value - chosen_value;

        explanation_sum += productions[chosen].explanation_support;
        gap_sum += gap;

        out << trial << ","
            << condition << ","
            << n_productions << ","
            << uncertainty << ","
            << chosen << ","
            << best << ","
            << success << ","
            << productions[chosen].explanation_support << ","
            << gap << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Success rate: " << static_cast<double>(success_count) / n << "\n";
    std::cout << "Mean explanation support: " << explanation_sum / n << "\n";
    std::cout << "Mean utility gap: " << gap_sum / n << "\n";

    return 0;
}
