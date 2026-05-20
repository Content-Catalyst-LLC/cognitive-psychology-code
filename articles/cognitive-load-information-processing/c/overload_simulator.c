#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast cognitive overload simulator.
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
    if (argc > 1) n = atoi(argv[1]);

    srand((unsigned int) time(NULL));

    double success_sum = 0.0;
    double overload_sum = 0.0;
    double efficiency_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double prior = uniform_range(0.0, 10.0);
        double capacity = uniform_range(3.0, 9.0) + 0.15 * prior;
        double intrinsic = uniform_range(0.0, 10.0);
        double extraneous = uniform_range(0.0, 10.0);
        double germane = uniform_range(0.0, 10.0);
        double total_load = intrinsic + extraneous + 0.55 * germane;
        double margin = capacity + 0.45 * prior - total_load;
        double p_success = logistic(-0.6 + 0.55 * margin + 0.24 * germane - 0.22 * extraneous);
        double effort = 4.0 + 0.35 * intrinsic + 0.50 * extraneous + 0.18 * germane - 0.22 * prior;
        if (effort < 0.0) effort = 0.0;
        if (effort > 10.0) effort = 10.0;
        double efficiency = (p_success - effort / 10.0) / sqrt(2.0);

        success_sum += p_success;
        overload_sum += margin < 0.0 ? 1.0 : 0.0;
        efficiency_sum += efficiency;
    }

    printf("Trials: %d\n", n);
    printf("Mean success probability: %.3f\n", success_sum / n);
    printf("Overload rate: %.3f\n", overload_sum / n);
    printf("Mean mental efficiency: %.3f\n", efficiency_sum / n);

    return 0;
}
