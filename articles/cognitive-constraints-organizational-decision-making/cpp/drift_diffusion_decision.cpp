#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

/*
 * Evidence-accumulation model for organizational decision tasks.
 *
 * Cognitive burden reduces drift rate and raises the probability of
 * slow or low-quality decisions. This is not a complete cognitive model,
 * but it provides a useful computational scaffold for researchers.
 */

struct TrialResult {
    std::string condition;
    double burden;
    double drift;
    double response_time;
    int correct;
};

TrialResult simulate_trial(std::mt19937 &rng, const std::string &condition) {
    std::normal_distribution<double> noise(0.0, 1.0);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);

    bool overload = condition == "overload";

    double info = overload ? 7.5 + noise(rng) : 4.0 + noise(rng);
    double uncertainty = overload ? 7.0 + noise(rng) : 4.2 + noise(rng);
    double coordination = overload ? 6.8 + noise(rng) : 4.3 + noise(rng);
    double pressure = overload ? 6.5 + noise(rng) : 4.1 + noise(rng);
    double safety = overload ? 4.5 + noise(rng) : 7.0 + noise(rng);

    double burden = info + uncertainty + coordination + pressure - 0.60 * safety;
    double drift = 1.25 - 0.035 * burden + 0.04 * safety;

    if (drift < 0.05) drift = 0.05;

    double boundary = overload ? 1.15 : 1.0;
    double nondecision_time = 0.35;
    double response_time = nondecision_time + boundary / drift + std::abs(noise(rng)) * 0.15;

    double accuracy_probability = 1.0 / (1.0 + std::exp(-3.0 * (drift - 0.55)));
    int correct = uniform(rng) < accuracy_probability ? 1 : 0;

    return TrialResult{condition, burden, drift, response_time, correct};
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_ddm_summary.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::ofstream out(output);

    out << "trial,condition,burden,drift,response_time,correct\n";

    int n = 5000;
    double accuracy_sum = 0.0;
    double rt_sum = 0.0;

    for (int i = 1; i <= n; i++) {
        std::string condition = (i % 2 == 0) ? "overload" : "baseline";
        TrialResult r = simulate_trial(rng, condition);

        out << i << ","
            << r.condition << ","
            << r.burden << ","
            << r.drift << ","
            << r.response_time << ","
            << r.correct << "\n";

        accuracy_sum += r.correct;
        rt_sum += r.response_time;
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Mean accuracy: " << accuracy_sum / n << "\n";
    std::cout << "Mean response time: " << rt_sum / n << "\n";

    return 0;
}
