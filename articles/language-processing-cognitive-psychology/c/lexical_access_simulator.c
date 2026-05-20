#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight lexical-access and reading-time simulator.
 *
 * Lexical access improves with word frequency, semantic predictability,
 * and context support. It becomes slower under lexical ambiguity,
 * syntactic complexity, and working-memory load.
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

    double comprehension_sum = 0.0;
    double lexical_sum = 0.0;
    double reading_sum = 0.0;
    int high_burden_cases = 0;

    for (int i = 0; i < n; i++) {
        double frequency = uniform_range(0.0, 10.0);
        double ambiguity = uniform_range(0.0, 10.0);
        double syntax = uniform_range(0.0, 10.0);
        double predictability = uniform_range(0.0, 10.0);
        double context = uniform_range(0.0, 10.0);
        double wm = uniform_range(0.0, 10.0);
        double pragmatic = uniform_range(0.0, 10.0);
        double discourse = uniform_range(0.0, 10.0);

        double comprehension_p = logistic(
            -1.0 +
            0.22 * frequency -
            0.24 * ambiguity -
            0.30 * syntax +
            0.24 * predictability +
            0.20 * context -
            0.24 * wm -
            0.18 * pragmatic +
            0.25 * discourse
        );

        double lexical_p = logistic(
            -0.6 +
            0.34 * frequency -
            0.18 * ambiguity +
            0.16 * predictability -
            0.12 * wm
        );

        double reading_time = exp(
            log(1200.0) -
            0.045 * frequency +
            0.060 * ambiguity +
            0.080 * syntax -
            0.045 * predictability -
            0.030 * context +
            0.065 * wm +
            0.025 * pragmatic -
            0.025 * comprehension_p
        );

        if (syntax > 8.0 || wm > 8.0 || pragmatic > 8.0) high_burden_cases++;

        comprehension_sum += comprehension_p;
        lexical_sum += lexical_p;
        reading_sum += reading_time;
    }

    printf("Trials: %d\n", n);
    printf("High processing-burden cases: %d\n", high_burden_cases);
    printf("Mean comprehension probability: %.3f\n", comprehension_sum / n);
    printf("Mean lexical decision probability: %.3f\n", lexical_sum / n);
    printf("Mean reading time estimate: %.3f ms\n", reading_sum / n);

    return 0;
}
