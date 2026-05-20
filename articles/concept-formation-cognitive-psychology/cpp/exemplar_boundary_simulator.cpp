#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>

/*
 * Exemplar-memory and boundary-classification simulation.
 *
 * A new item is compared against stored exemplars. High accumulated similarity
 * to one category and low similarity to competitors produces higher confidence
 * and faster classification.
 */

struct Point {
    double x;
    double y;
};

double dist(Point a, Point b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return std::sqrt(dx * dx + dy * dy);
}

double sim(Point a, Point b, double lambda) {
    return std::exp(-lambda * dist(a, b));
}

int main(int argc, char **argv) {
    std::string output = "../outputs/cpp_exemplar_boundary.csv";
    if (argc > 1) {
        output = argv[1];
    }

    std::mt19937 rng(42);
    std::normal_distribution<double> noise(0.0, 0.12);
    std::uniform_real_distribution<double> uniform(0.0, 1.0);

    std::vector<Point> a_exemplars = {{0.2, 0.2}, {0.25, 0.18}, {0.18, 0.25}, {0.28, 0.24}};
    std::vector<Point> b_exemplars = {{0.8, 0.2}, {0.75, 0.18}, {0.82, 0.25}, {0.70, 0.23}};
    std::vector<Point> c_exemplars = {{0.5, 0.8}, {0.45, 0.78}, {0.55, 0.76}, {0.50, 0.88}};

    std::ofstream out(output);
    out << "trial,true_category,predicted_category,score_a,score_b,score_c,boundary_ambiguity,correct,response_time_ms\n";

    int n = 5000;
    int correct_count = 0;
    double ambiguity_sum = 0.0;

    for (int trial = 1; trial <= n; ++trial) {
        int true_cat = static_cast<int>(uniform(rng) * 3.0);
        Point center = true_cat == 0 ? Point{0.2, 0.2} : (true_cat == 1 ? Point{0.8, 0.2} : Point{0.5, 0.8});
        double scale = uniform(rng) < 0.20 ? 0.25 : 0.12;
        Point item{center.x + scale * noise(rng) / 0.12, center.y + scale * noise(rng) / 0.12};

        double lambda = 4.5;
        double score_a = 0.0, score_b = 0.0, score_c = 0.0;

        for (auto p : a_exemplars) score_a += sim(item, p, lambda);
        for (auto p : b_exemplars) score_b += sim(item, p, lambda);
        for (auto p : c_exemplars) score_c += sim(item, p, lambda);

        double scores[3] = {score_a, score_b, score_c};
        int pred = 0;
        if (score_b > scores[pred]) pred = 1;
        if (score_c > scores[pred]) pred = 2;

        double best = scores[pred];
        double second = 0.0;
        for (int i = 0; i < 3; i++) {
            if (i != pred && scores[i] > second) second = scores[i];
        }

        double ambiguity = 1.0 - std::fabs(best - second) / (best + second + 1e-9);
        int correct = pred == true_cat ? 1 : 0;
        double response_time = std::exp(std::log(1200.0) + 0.45 * ambiguity - 0.25 * correct + 0.05 * noise(rng));

        correct_count += correct;
        ambiguity_sum += ambiguity;

        std::string true_label = true_cat == 0 ? "Category_A" : (true_cat == 1 ? "Category_B" : "Category_C");
        std::string pred_label = pred == 0 ? "Category_A" : (pred == 1 ? "Category_B" : "Category_C");

        out << trial << ","
            << true_label << ","
            << pred_label << ","
            << score_a << ","
            << score_b << ","
            << score_c << ","
            << ambiguity << ","
            << correct << ","
            << response_time << "\n";
    }

    std::cout << "Wrote simulation to: " << output << "\n";
    std::cout << "Accuracy rate: " << static_cast<double>(correct_count) / n << "\n";
    std::cout << "Mean boundary ambiguity: " << ambiguity_sum / n << "\n";

    return 0;
}
