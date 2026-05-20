#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>

double logistic(double x) { if (x > 40) return 1; if (x < -40) return 0; return 1.0 / (1.0 + std::exp(-x)); }

int main(int argc, char **argv) {
    std::string output = argc > 1 ? argv[1] : "../outputs/cpp_misinformation_source.csv";
    std::mt19937 rng(42);
    std::uniform_real_distribution<double> u(0, 1);
    std::normal_distribution<double> z(0, 1);
    std::ofstream out(output);
    out << "trial,condition,old_item,misinformation,source_context,interference,response_old,source_correct,false_memory\n";
    int n = 5000, fc = 0, fm = 0, nc = 0, nm = 0;
    for (int t = 1; t <= n; ++t) {
        bool mis = u(rng) < 0.5, old = u(rng) < 0.60;
        double source = std::max(0.0, std::min(10.0, 5.5 + 1.2*z(rng) - (mis ? 1.2 : 0.0)));
        double inter = std::max(0.0, std::min(10.0, 3.0 + z(rng) + (mis ? 2.0 : 0.0)));
        double pold = old ? logistic(0.9 + 0.22*source - 0.12*inter) : logistic(-2.0 + 0.22*inter - 0.12*source + (mis ? 0.80 : 0.0));
        bool response = u(rng) < pold;
        bool source_correct = u(rng) < logistic(-0.6 + 0.32*source - 0.18*inter - (mis ? 0.45 : 0.0));
        bool false_memory = !old && response;
        if (!old && mis) { nm++; if (false_memory) fm++; }
        if (!old && !mis) { nc++; if (false_memory) fc++; }
        out << t << "," << (mis ? "misinformation" : "control") << "," << old << "," << mis << "," << source << "," << inter << "," << response << "," << source_correct << "," << false_memory << "\n";
    }
    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Control false-memory rate: " << (double)fc/nc << "\n";
    std::cout << "Misinformation false-memory rate: " << (double)fm/nm << "\n";
}
