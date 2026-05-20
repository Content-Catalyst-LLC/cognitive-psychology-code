#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Study-allocation and control simulation.
 *
 * Models how confidence, uncertainty, difficulty, feedback, and calibration
 * influence review choice and study-time allocation.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_study_allocation.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,difficulty,evidence,confidence,accuracy,calibration_error,review_probability,study_time_seconds\n";

    int n = 5000;
    double calibration_sum = 0.0;
    double review_sum = 0.0;
    double study_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool feedback = uniform(rng) < 0.50;
        bool prompt = uniform(rng) < 0.50;
        std::string condition = feedback && prompt ? "strategy_training" : (feedback ? "feedback" : (prompt ? "metacognitive_prompt" : "control"));

        double difficulty = 2.0 + 8.0 * uniform(rng);
        double evidence = 2.0 + 8.0 * uniform(rng);
        double skill = noise(rng);

        double accuracy_p = logistic(0.2 + 0.25 * evidence - 0.32 * difficulty + 0.35 * skill);
        double accuracy = uniform(rng) < accuracy_p ? 1.0 : 0.0;

        double confidence = 0.48 + 0.26 * accuracy - 0.03 * difficulty + 0.02 * evidence + 0.06 * skill + 0.04 * prompt + 0.10 * noise(rng);
        if (confidence < 0.0) confidence = 0.0;
        if (confidence > 1.0) confidence = 1.0;

        double uncertainty = 1.0 - confidence;
        double calibration_error = std::fabs(confidence - accuracy);
        double review_p = logistic(-1.0 + 1.8 * calibration_error + 1.2 * uncertainty + 0.16 * difficulty + 0.25 * prompt + 0.22 * feedback);
        double study_time = 15.0 + 3.0 * difficulty + 18.0 * uncertainty - 8.0 * confidence + 7.0 * review_p + 4.0 * feedback + 3.0 * noise(rng);

        if (study_time < 0.0) study_time = 0.0;

        calibration_sum += calibration_error;
        review_sum += review_p;
        study_sum += study_time;

        out << trial << ","
            << condition << ","
            << difficulty << ","
            << evidence << ","
            << confidence << ","
            << accuracy << ","
            << calibration_error << ","
            << review_p << ","
            << study_time << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean calibration error: " << calibration_sum / n << "\n";
    std::cout << "Mean review probability: " << review_sum / n << "\n";
    std::cout << "Mean study time: " << study_sum / n << " seconds\n";

    return 0;
}
