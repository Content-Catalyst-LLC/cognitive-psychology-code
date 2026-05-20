#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast prediction-error simulator for mental models.
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) n = atoi(argv[1]);

    srand((unsigned int) time(NULL));

    double error_sum = 0.0;
    double understanding_sum = 0.0;
    double success_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double completeness = uniform_range(0.0, 10.0);
        double coherence = uniform_range(0.0, 10.0);
        double causal = uniform_range(0.0, 10.0);
        double loops = uniform_range(0.0, 10.0);
        double boundaries = uniform_range(0.0, 10.0);
        double complexity = uniform_range(0.0, 10.0);

        double quality = 0.20 * completeness + 0.22 * coherence + 0.24 * causal + 0.18 * loops + 0.16 * boundaries;
        double error = 30.0 - 2.3 * quality + 1.6 * complexity;
        if (error < 0.0) error = 0.0;

        double understanding = 8.0 * quality - 1.4 * complexity;
        if (understanding < 0.0) understanding = 0.0;
        if (understanding > 100.0) understanding = 100.0;

        double success = understanding > 55.0 && error < 14.0 ? 1.0 : 0.0;

        error_sum += error;
        understanding_sum += understanding;
        success_sum += success;
    }

    printf("Trials: %d\n", n);
    printf("Mean prediction error: %.3f\n", error_sum / n);
    printf("Mean system understanding: %.3f\n", understanding_sum / n);
    printf("Problem success rate: %.3f\n", success_sum / n);

    return 0;
}
