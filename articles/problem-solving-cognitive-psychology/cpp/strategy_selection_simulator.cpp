#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>

/*
 * Strategy-selection and search-cost simulation.
 *
 * Strategies are selected as a function of expected usefulness, effort cost,
 * familiarity, and problem difficulty. This supports teaching and exploratory
 * modeling of human problem-solving strategy choice.
 */

struct Strategy {
    std::string name;
    double usefulness;
    double effort;
    double familiarity;
};

double softmax_score(const Strategy& s, double beta_u, double beta_e, double beta_f) {
    return std::exp(beta_u * s.usefulness - beta_e * s.effort + beta_f * s.familiarity);
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_strategy_selection.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,problem_difficulty,wm_load,selected_strategy,selected_usefulness,selected_effort,success_probability,solution_quality\n";

    int n = 5000;
    double success_sum = 0.0;
    double quality_sum = 0.0;

    std::vector<std::string> names = {"algorithmic", "heuristic", "means_end", "analogical", "decomposition", "trial_error"};

    for (int trial = 1; trial <= n; ++trial) {
        double difficulty = 2.0 + 8.0 * uniform(rng);
        double wm_load = 2.0 + 8.0 * uniform(rng);
        double representation = 2.0 + 8.0 * uniform(rng);

        std::vector<Strategy> strategies;
        for (const auto& name : names) {
            double base_usefulness = 5.0 + noise(rng);
            double effort = 3.0 + 6.0 * uniform(rng);
            double familiarity = 2.0 + 8.0 * uniform(rng);

            if (name == "algorithmic") {
                base_usefulness += 1.2;
                effort += 1.8;
            } else if (name == "heuristic") {
                base_usefulness -= 0.4;
                effort -= 1.0;
            } else if (name == "analogical") {
                base_usefulness += 0.8;
                effort += 0.6;
            } else if (name == "decomposition") {
                base_usefulness += 0.9;
                effort += 0.9;
            } else if (name == "trial_error") {
                base_usefulness -= 0.8;
                effort -= 0.4;
            }

            strategies.push_back({name, base_usefulness, effort, familiarity});
        }

        double total = 0.0;
        std::vector<double> weights;
        for (const auto& s : strategies) {
            double w = softmax_score(s, 0.70, 0.35 + 0.04 * wm_load, 0.25);
            weights.push_back(w);
            total += w;
        }

        double r = uniform(rng) * total;
        int selected = 0;
        double cumulative = 0.0;
        for (int i = 0; i < static_cast<int>(weights.size()); ++i) {
            cumulative += weights[i];
            if (r <= cumulative) {
                selected = i;
                break;
            }
        }

        Strategy s = strategies[selected];
        double success_p = 1.0 / (1.0 + std::exp(-(-2.0 + 0.38 * representation + 0.35 * s.usefulness - 0.18 * s.effort - 0.25 * difficulty - 0.20 * wm_load)));
        double quality = 35.0 + 5.0 * representation + 6.0 * success_p + 2.5 * s.usefulness - 1.2 * s.effort - 2.0 * difficulty;

        if (quality < 0.0) quality = 0.0;
        if (quality > 100.0) quality = 100.0;

        success_sum += success_p;
        quality_sum += quality;

        out << trial << ","
            << difficulty << ","
            << wm_load << ","
            << s.name << ","
            << s.usefulness << ","
            << s.effort << ","
            << success_p << ","
            << quality << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean success probability: " << success_sum / n << "\n";
    std::cout << "Mean solution quality: " << quality_sum / n << "\n";

    return 0;
}
