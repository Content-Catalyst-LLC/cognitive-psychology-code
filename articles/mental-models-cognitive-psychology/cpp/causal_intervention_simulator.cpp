#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Causal-network and intervention simulation for mental-model research.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_causal_interventions.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,causal_accuracy,feedback_loop_recognition,boundary_accuracy,complexity,prediction_error,intervention_accuracy,system_understanding\n";

    int n = 5000;
    double intervention_sum = 0.0;
    double error_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool training = uniform(rng) < 0.45;
        bool feedback = uniform(rng) < 0.50;
        bool complex = uniform(rng) < 0.40;
        std::string condition = training ? "model_training" : (feedback ? "feedback" : (complex ? "complex_system" : "control"));

        double complexity = complex ? 7.0 + 3.0 * uniform(rng) : 3.0 + 4.0 * uniform(rng);
        double causal = 4.5 + 2.0 * training + 1.2 * feedback - 0.10 * complexity + noise(rng);
        double loops = 3.5 + 1.4 * training + 1.6 * feedback - 0.08 * complexity + noise(rng);
        double boundary = 4.5 + 1.4 * training + 0.8 * feedback - 0.06 * complexity + noise(rng);

        if (causal < 0.0) causal = 0.0;
        if (causal > 10.0) causal = 10.0;
        if (loops < 0.0) loops = 0.0;
        if (loops > 10.0) loops = 10.0;
        if (boundary < 0.0) boundary = 0.0;
        if (boundary > 10.0) boundary = 10.0;

        double understanding = 10.0 * (0.36 * causal + 0.34 * loops + 0.30 * boundary) - 1.4 * complexity;
        if (understanding < 0.0) understanding = 0.0;
        if (understanding > 100.0) understanding = 100.0;

        double prediction_error = 28.0 - 2.1 * causal - 1.7 * loops - 1.4 * boundary + 1.5 * complexity + 2.5 * noise(rng);
        if (prediction_error < 0.0) prediction_error = 0.0;

        double intervention_p = logistic(-2.2 + 0.14 * causal + 0.14 * loops + 0.10 * boundary + 0.04 * understanding - 0.09 * prediction_error);
        double intervention = uniform(rng) < intervention_p ? 1.0 : 0.0;

        intervention_sum += intervention;
        error_sum += prediction_error;

        out << trial << "," << condition << "," << causal << "," << loops << "," << boundary << ","
            << complexity << "," << prediction_error << "," << intervention << "," << understanding << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean intervention accuracy: " << intervention_sum / n << "\n";
    std::cout << "Mean prediction error: " << error_sum / n << "\n";
    return 0;
}
