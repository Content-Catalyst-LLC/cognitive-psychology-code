#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight semantic-memory activation simulator.
 *
 * Retrieval probability increases with category typicality, feature overlap,
 * associative strength, and familiarity, and decreases with semantic distance
 * and false association.
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

static double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + exp(-x));
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) {
        n = atoi(argv[1]);
    }

    srand((unsigned int) time(NULL));

    double accuracy_sum = 0.0;
    double rt_sum = 0.0;
    double category_sum = 0.0;
    int false_association_cases = 0;

    for (int i = 0; i < n; i++) {
        double distance = uniform_range(0.0, 10.0);
        double typicality = uniform_range(0.0, 10.0);
        double feature_overlap = uniform_range(0.0, 10.0);
        double associative_strength = uniform_range(0.0, 10.0);
        double familiarity = uniform_range(0.0, 10.0);
        double false_association = uniform01() < 0.20 ? 1.0 : 0.0;

        double accuracy_p = logistic(
            -0.8 -
            0.22 * distance +
            0.24 * typicality +
            0.18 * feature_overlap +
            0.14 * associative_strength +
            0.15 * familiarity -
            0.75 * false_association
        );

        double category_strength = 1.2 + 0.50 * typicality + 0.22 * feature_overlap - 0.20 * distance - 0.60 * false_association;
        if (category_strength < 0.0) category_strength = 0.0;
        if (category_strength > 10.0) category_strength = 10.0;

        double response_time = exp(log(1200.0) + 0.07 * distance - 0.035 * typicality - 0.030 * associative_strength + 0.095 * false_association);

        if (false_association > 0.5) false_association_cases++;

        accuracy_sum += accuracy_p;
        rt_sum += response_time;
        category_sum += category_strength;
    }

    printf("Trials: %d\n", n);
    printf("False-association cases: %d\n", false_association_cases);
    printf("Mean verification accuracy probability: %.3f\n", accuracy_sum / n);
    printf("Mean category strength: %.3f\n", category_sum / n);
    printf("Mean retrieval time estimate: %.3f ms\n", rt_sum / n);

    return 0;
}
