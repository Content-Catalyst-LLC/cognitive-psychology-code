#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Retrieval-practice and transfer simulation.
 */

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_retrieval_transfer.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,session,retrieval_practice,feedback_quality,cognitive_load,schema_strength,comprehension_score,transfer_score,retention_score\n";

    int n = 5000;
    double transfer_sum = 0.0;
    double retention_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool retrieval = uniform(rng) < 0.55;
        bool spaced = uniform(rng) < 0.35;
        bool high_feedback = uniform(rng) < 0.45;
        std::string condition = retrieval ? "retrieval_practice" : "control";
        if (spaced) condition = "spaced_practice";
        if (high_feedback) condition = "feedback_rich";

        double session = 1.0 + 7.0 * uniform(rng);
        double feedback = high_feedback ? 7.0 + 3.0 * uniform(rng) : 3.0 + 5.0 * uniform(rng);
        double load = 3.0 + 6.0 * uniform(rng);
        double prior = 3.0 + 6.0 * uniform(rng);
        double attention = 4.0 + 5.0 * uniform(rng);
        double schema = 3.5 + 0.35 * session + 0.25 * prior + 0.20 * attention + 0.70 * retrieval + 0.4 * noise(rng);

        if (schema < 0.0) schema = 0.0;
        if (schema > 10.0) schema = 10.0;

        double comprehension = 24.0 + 2.8 * attention + 2.8 * schema + 2.0 * feedback + 4.0 * retrieval - 1.8 * load + 4.0 * noise(rng);
        double transfer = 20.0 + 0.42 * comprehension + 2.5 * schema + 4.0 * retrieval - 1.5 * load + 5.0 * noise(rng);
        double retention = 23.0 + 0.40 * comprehension + 5.5 * retrieval + 5.0 * spaced + 1.7 * schema - 1.2 * load + 5.0 * noise(rng);

        if (comprehension < 0.0) comprehension = 0.0;
        if (comprehension > 100.0) comprehension = 100.0;
        if (transfer < 0.0) transfer = 0.0;
        if (transfer > 100.0) transfer = 100.0;
        if (retention < 0.0) retention = 0.0;
        if (retention > 100.0) retention = 100.0;

        transfer_sum += transfer;
        retention_sum += retention;

        out << trial << "," << condition << "," << session << "," << (retrieval ? 1 : 0) << ","
            << feedback << "," << load << "," << schema << "," << comprehension << ","
            << transfer << "," << retention << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean transfer score: " << transfer_sum / n << "\n";
    std::cout << "Mean retention score: " << retention_sum / n << "\n";
    return 0;
}
