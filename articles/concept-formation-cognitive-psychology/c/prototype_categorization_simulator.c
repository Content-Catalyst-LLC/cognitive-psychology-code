#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight prototype-distance categorization simulator.
 *
 * Categorization accuracy improves when prototype distance is low,
 * competing-category distance is high, feature diagnosticity is high,
 * and boundary ambiguity is low.
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
    double generalization_sum = 0.0;
    double ambiguity_sum = 0.0;
    int boundary_cases = 0;

    for (int i = 0; i < n; i++) {
        double prototype_distance = uniform_range(0.0, 10.0);
        double competing_distance = uniform_range(0.0, 10.0);
        double exemplar_similarity = uniform_range(0.0, 10.0);
        double feature_diagnosticity = uniform_range(0.0, 10.0);
        double rule_consistency = uniform_range(0.0, 10.0);
        double boundary_ambiguity = 10.0 - fabs(competing_distance - prototype_distance);

        if (boundary_ambiguity < 0.0) boundary_ambiguity = 0.0;
        if (boundary_ambiguity > 10.0) boundary_ambiguity = 10.0;

        double accuracy_p = logistic(
            -1.1 -
            0.28 * prototype_distance +
            0.16 * competing_distance +
            0.24 * exemplar_similarity +
            0.26 * feature_diagnosticity +
            0.18 * rule_consistency -
            0.30 * boundary_ambiguity
        );

        double generalization = 35.0 + 45.0 * accuracy_p + 1.8 * feature_diagnosticity - 1.2 * boundary_ambiguity;

        if (generalization < 0.0) generalization = 0.0;
        if (generalization > 100.0) generalization = 100.0;

        if (boundary_ambiguity > 7.0) boundary_cases++;

        accuracy_sum += accuracy_p;
        generalization_sum += generalization;
        ambiguity_sum += boundary_ambiguity;
    }

    printf("Trials: %d\n", n);
    printf("Boundary cases: %d\n", boundary_cases);
    printf("Mean categorization accuracy probability: %.3f\n", accuracy_sum / n);
    printf("Mean generalization score: %.3f\n", generalization_sum / n);
    printf("Mean boundary ambiguity: %.3f\n", ambiguity_sum / n);

    return 0;
}
