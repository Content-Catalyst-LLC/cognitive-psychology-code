#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Partial-report and selection simulator.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_partial_report_selection.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,cue_delay_ms,trace_strength,salience,priority,mask,selection_probability,correct,report_score\n";

    int n = 5000;
    double partial_sum = 0.0;
    double whole_sum = 0.0;
    int partial_n = 0;
    int whole_n = 0;

    for (int trial = 1; trial <= n; ++trial) {
        bool partial = uniform(rng) < 0.55;
        bool mask = uniform(rng) < 0.25;
        std::string condition = partial ? "partial_report" : "whole_report";

        double delay = 700.0 * uniform(rng);
        double trace = std::exp(-0.0048 * delay) + 0.03 * noise(rng);
        if (mask) trace *= 0.55;
        if (trace < 0.0) trace = 0.0;
        if (trace > 1.0) trace = 1.0;

        double salience = 10.0 * uniform(rng);
        double priority = partial ? 7.0 + 2.0 * uniform(rng) : 2.0 + 3.0 * uniform(rng);

        double selection = logistic(-1.2 + 3.1 * trace + 0.18 * salience + 0.28 * priority - 0.45 * mask);
        double correct = uniform(rng) < selection ? 1.0 : 0.0;
        double report = partial ? (1.0 + 2.5 * correct + 0.1 * priority) : (2.5 + 2.0 * correct + 0.05 * salience);
        if (report < 0.0) report = 0.0;

        if (partial) {
            partial_sum += report;
            partial_n++;
        } else {
            whole_sum += report;
            whole_n++;
        }

        out << trial << "," << condition << "," << delay << "," << trace << "," << salience << ","
            << priority << "," << (mask ? 1 : 0) << "," << selection << "," << correct << "," << report << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean partial report: " << partial_sum / partial_n << "\n";
    std::cout << "Mean whole report: " << whole_sum / whole_n << "\n";
    std::cout << "Partial-report advantage estimate: " << (partial_sum / partial_n) - (whole_sum / whole_n) << "\n";
    return 0;
}
