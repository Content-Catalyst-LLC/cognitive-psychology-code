#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_visual_search.csv";
    if (argc > 1) output = argv[1];

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,set_size,distractor_similarity,target_present,attention_gain,interface_salience,correct,rt_ms\n";

    int n = 5000;
    int correct_sum = 0;
    double rt_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        int set_size = 1 + (int)(30.0 * uniform(rng));
        double distractor_similarity = 10.0 * uniform(rng);
        bool target_present = uniform(rng) < 0.55;
        double attention_gain = 3.0 + 6.0 * uniform(rng);
        double interface_salience = 10.0 * uniform(rng);

        double accuracy_prob = logistic(2.0 + 0.22 * attention_gain + 0.20 * interface_salience - 0.06 * set_size - 0.22 * distractor_similarity);
        int correct = uniform(rng) < accuracy_prob ? 1 : 0;
        double rt_ms = std::exp(std::log(700.0) + 0.020 * set_size + 0.045 * distractor_similarity - 0.030 * attention_gain - 0.025 * interface_salience + 0.12 * noise(rng));

        correct_sum += correct;
        rt_sum += rt_ms;

        out << trial << "," << set_size << "," << distractor_similarity << "," << (target_present ? 1 : 0)
            << "," << attention_gain << "," << interface_salience << "," << correct << "," << rt_ms << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Correct rate: " << (double)correct_sum / n << "\n";
    std::cout << "Mean RT ms: " << rt_sum / n << "\n";
    return 0;
}
