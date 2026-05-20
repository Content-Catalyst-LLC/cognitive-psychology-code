#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>

/*
 * Candidate source retrieval and structure-mapping simulation.
 *
 * Surface similarity can help retrieve a source, but structural similarity
 * determines whether transfer is useful. This separation is central to
 * analogical-reasoning research.
 */

struct SourceCandidate {
    double surface_similarity;
    double structural_similarity;
    double familiarity;
};

double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + std::exp(-x));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_source_retrieval.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);
    std::normal_distribution<double> noise(0.0, 1.0);

    std::ofstream out(output);
    out << "trial,condition,n_sources,retrieved_surface,retrieved_structure,best_structure,mapping_probability,transfer_probability,misleading_retrieval\n";

    int n = 5000;
    int misleading_count = 0;
    double mapping_sum = 0.0;
    double transfer_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        bool high_surface_condition = uniform(rng) < 0.45;
        std::string condition = high_surface_condition ? "surface_match" : "structure_match";
        int n_sources = 6;

        std::vector<SourceCandidate> sources;

        for (int i = 0; i < n_sources; ++i) {
            double surface = high_surface_condition ? 5.0 + 5.0 * uniform(rng) : 2.0 + 5.0 * uniform(rng);
            double structure = high_surface_condition ? 2.0 + 6.0 * uniform(rng) : 5.0 + 5.0 * uniform(rng);
            double familiarity = 3.0 + 7.0 * uniform(rng);
            sources.push_back({surface, structure, familiarity});
        }

        int retrieved = 0;
        double retrieval_score = -1e9;

        for (int i = 0; i < n_sources; ++i) {
            double score = 0.72 * sources[i].surface_similarity + 0.30 * sources[i].familiarity + 0.15 * noise(rng);
            if (score > retrieval_score) {
                retrieval_score = score;
                retrieved = i;
            }
        }

        int best = 0;
        for (int i = 1; i < n_sources; ++i) {
            if (sources[i].structural_similarity > sources[best].structural_similarity) {
                best = i;
            }
        }

        double complexity = 4.0 + 5.0 * uniform(rng);
        double wm = 2.0 + 0.60 * complexity + std::abs(noise(rng));

        double mapping_p = logistic(
            -2.0 +
            0.58 * sources[retrieved].structural_similarity +
            0.22 * sources[retrieved].familiarity -
            0.32 * complexity -
            0.18 * wm
        );

        double transfer_p = logistic(
            -2.3 +
            0.65 * sources[retrieved].structural_similarity +
            0.75 * mapping_p -
            0.28 * complexity -
            0.18 * wm
        );

        int misleading = sources[retrieved].surface_similarity > 7.0 && sources[retrieved].structural_similarity < sources[best].structural_similarity - 2.0;
        if (misleading) misleading_count++;

        mapping_sum += mapping_p;
        transfer_sum += transfer_p;

        out << trial << ","
            << condition << ","
            << n_sources << ","
            << sources[retrieved].surface_similarity << ","
            << sources[retrieved].structural_similarity << ","
            << sources[best].structural_similarity << ","
            << mapping_p << ","
            << transfer_p << ","
            << misleading << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Misleading retrieval rate: " << static_cast<double>(misleading_count) / n << "\n";
    std::cout << "Mean mapping probability: " << mapping_sum / n << "\n";
    std::cout << "Mean transfer probability: " << transfer_sum / n << "\n";

    return 0;
}
