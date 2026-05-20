#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Sentence-processing and ambiguity-resolution simulation.
 *
 * The model computes comprehension probability and reading time as a function
 * of syntactic complexity, lexical ambiguity, semantic predictability,
 * context support, working-memory load, and discourse coherence.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_sentence_processing.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,syntax,ambiguity,predictability,context,wm_load,discourse,comprehension_probability,reading_time_ms\n";

    int n = 5000;
    double comprehension_sum = 0.0;
    double reading_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        int condition_code = static_cast<int>(uniform(rng) * 4.0);
        std::string condition = "control";

        double syntax = 3.0 + 5.0 * uniform(rng);
        double ambiguity = 2.0 + 6.0 * uniform(rng);
        double predictability = 3.0 + 6.0 * uniform(rng);
        double context = 3.0 + 6.0 * uniform(rng);
        double pragmatic = 2.0 + 5.0 * uniform(rng);

        if (condition_code == 1) {
            condition = "syntactic_complexity";
            syntax = 7.5 + 2.0 * uniform(rng);
        } else if (condition_code == 2) {
            condition = "semantic_prime";
            predictability = 7.5 + 2.0 * uniform(rng);
            context = 7.0 + 2.0 * uniform(rng);
        } else if (condition_code == 3) {
            condition = "pragmatic_inference";
            pragmatic = 7.5 + 2.0 * uniform(rng);
        }

        double frequency = 4.0 + 5.0 * uniform(rng);
        double wm = 2.0 + 0.55 * syntax + 0.25 * ambiguity + 0.20 * pragmatic - 0.20 * context + 0.6 * noise(rng);
        if (wm < 0.0) wm = 0.0;
        if (wm > 10.0) wm = 10.0;

        double discourse = 0.45 * context + 0.40 * predictability + 1.5 * uniform(rng);
        if (discourse > 10.0) discourse = 10.0;

        double comprehension_p = logistic(
            -1.0 +
            0.22 * frequency -
            0.24 * ambiguity -
            0.30 * syntax +
            0.24 * predictability +
            0.20 * context -
            0.24 * wm -
            0.18 * pragmatic +
            0.25 * discourse
        );

        double reading_time = std::exp(
            std::log(1200.0) -
            0.045 * frequency +
            0.060 * ambiguity +
            0.080 * syntax -
            0.045 * predictability -
            0.030 * context +
            0.065 * wm +
            0.025 * pragmatic -
            0.025 * comprehension_p +
            0.10 * noise(rng)
        );

        comprehension_sum += comprehension_p;
        reading_sum += reading_time;

        out << trial << ","
            << condition << ","
            << syntax << ","
            << ambiguity << ","
            << predictability << ","
            << context << ","
            << wm << ","
            << discourse << ","
            << comprehension_p << ","
            << reading_time << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean comprehension probability: " << comprehension_sum / n << "\n";
    std::cout << "Mean reading time estimate: " << reading_sum / n << " ms\n";

    return 0;
}
