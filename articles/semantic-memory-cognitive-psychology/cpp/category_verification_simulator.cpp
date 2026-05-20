#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Category-verification and retrieval-cost simulation.
 *
 * Models semantic verification as a function of semantic distance,
 * category typicality, feature overlap, associative strength, and false
 * semantic association.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_category_verification.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,semantic_distance,category_typicality,feature_overlap,associative_strength,false_association,accuracy_probability,response_time_ms\n";

    int n = 5000;
    double accuracy_sum = 0.0;
    double rt_sum = 0.0;
    int false_cases = 0;

    for (int trial = 1; trial <= n; ++trial) {
        bool false_association = uniform(rng) < 0.20;
        std::string condition = false_association ? "false_related" : (uniform(rng) < 0.50 ? "semantic_prime" : "control");

        double distance = false_association ? 2.0 + 4.0 * uniform(rng) : 0.5 + 8.0 * uniform(rng);
        double typicality = false_association ? 2.0 + 4.0 * uniform(rng) : 4.0 + 6.0 * uniform(rng);
        double feature = false_association ? 4.0 + 3.0 * uniform(rng) : 3.0 + 7.0 * uniform(rng);
        double associative = condition == "semantic_prime" || false_association ? 6.0 + 4.0 * uniform(rng) : 2.0 + 6.0 * uniform(rng);

        double p = logistic(
            -0.8 -
            0.22 * distance +
            0.24 * typicality +
            0.18 * feature +
            0.14 * associative -
            0.75 * false_association +
            0.15 * noise(rng)
        );

        double rt = std::exp(
            std::log(1200.0) +
            0.070 * distance -
            0.035 * typicality -
            0.030 * associative +
            0.095 * false_association +
            0.10 * noise(rng)
        );

        if (false_association) false_cases++;

        accuracy_sum += p;
        rt_sum += rt;

        out << trial << ","
            << condition << ","
            << distance << ","
            << typicality << ","
            << feature << ","
            << associative << ","
            << false_association << ","
            << p << ","
            << rt << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "False association rate: " << static_cast<double>(false_cases) / n << "\n";
    std::cout << "Mean accuracy probability: " << accuracy_sum / n << "\n";
    std::cout << "Mean response time estimate: " << rt_sum / n << " ms\n";

    return 0;
}
