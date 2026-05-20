#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Fitts-style pointing and decision-cost simulator.
 *
 * This is not a full HCI model. It provides a computational scaffold for
 * examining how target distance, target width, cognitive load, and alignment
 * affect movement time, errors, and task success.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_fitts_decision_summary.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,interface_condition,distance,width,index_of_difficulty,cognitive_load,alignment,movement_time_ms,error_probability,success\n";

    int n = 5000;
    int success_count = 0;
    double movement_sum = 0.0;
    double error_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool cluttered = uniform(rng) < 0.45;
        std::string condition = cluttered ? "cluttered" : "guided";

        double distance = 100.0 + 900.0 * uniform(rng);
        double width = cluttered ? 10.0 + 45.0 * uniform(rng) : 30.0 + 90.0 * uniform(rng);
        double id = std::log2(distance / width + 1.0);

        double cognitive_load = cluttered ? 6.5 + noise(rng) : 3.8 + noise(rng);
        double alignment = cluttered ? 4.8 + noise(rng) : 8.0 + noise(rng);

        double movement_time = 180.0 + 120.0 * id + 45.0 * cognitive_load - 25.0 * alignment + 30.0 * std::abs(noise(rng));
        if (movement_time < 50.0) movement_time = 50.0;

        double error_probability = logistic(-3.0 + 0.45 * id + 0.32 * cognitive_load - 0.25 * alignment);
        int success = uniform(rng) > error_probability ? 1 : 0;

        success_count += success;
        movement_sum += movement_time;
        error_sum += error_probability;

        out << trial << ","
            << condition << ","
            << distance << ","
            << width << ","
            << id << ","
            << cognitive_load << ","
            << alignment << ","
            << movement_time << ","
            << error_probability << ","
            << success << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Success rate: " << static_cast<double>(success_count) / n << "\n";
    std::cout << "Mean movement time: " << movement_sum / n << " ms\n";
    std::cout << "Mean error probability: " << error_sum / n << "\n";

    return 0;
}
