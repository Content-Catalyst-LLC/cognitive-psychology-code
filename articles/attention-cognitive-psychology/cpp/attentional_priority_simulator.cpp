#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Attentional-priority simulator.
 * Simulates priority-weighted selection from salience, goal relevance,
 * learned value, and uncertainty reduction.
 */

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_attentional_priority.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,set_size,target_present,salience,goal_relevance,value,uncertainty,priority,selected,correct,rt_ms\n";

    int n = 5000;
    int correct_sum = 0;
    double rt_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        int set_size = 2 + (int)(28.0 * uniform(rng));
        bool target_present = uniform(rng) < 0.55;
        double salience = 10.0 * uniform(rng);
        double goal = 10.0 * uniform(rng) + (target_present ? 2.0 : 0.0);
        double value = 10.0 * uniform(rng);
        double uncertainty = 10.0 * uniform(rng);
        double priority = std::exp(0.22 * salience + 0.28 * goal + 0.12 * value + 0.10 * uncertainty - 0.035 * set_size);
        double p_selected = priority / (1.0 + priority);
        bool selected = uniform(rng) < p_selected;
        double p_correct = logistic(1.5 + 0.12 * salience + 0.18 * goal - 0.05 * set_size + 0.45 * selected);
        int correct = uniform(rng) < p_correct ? 1 : 0;
        double rt_ms = std::exp(std::log(650.0) + 0.021 * set_size - 0.032 * salience - 0.034 * goal + 0.10 * noise(rng));

        correct_sum += correct;
        rt_sum += rt_ms;

        out << trial << "," << set_size << "," << (target_present ? 1 : 0) << ","
            << salience << "," << goal << "," << value << "," << uncertainty << ","
            << priority << "," << (selected ? 1 : 0) << "," << correct << "," << rt_ms << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Correct rate: " << (double)correct_sum / n << "\n";
    std::cout << "Mean RT ms: " << rt_sum / n << "\n";
    return 0;
}
