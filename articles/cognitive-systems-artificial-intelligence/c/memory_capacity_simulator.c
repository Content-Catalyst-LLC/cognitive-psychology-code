#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight simulation of retrieval latency and memory load
 * in cognitive AI systems.
 *
 * This is useful for teaching, methods appendices, or fast sensitivity checks.
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

    double latency_sum = 0.0;
    double accuracy_sum = 0.0;
    int overload_count = 0;

    for (int i = 0; i < n; i++) {
        double wm_load = uniform_range(0.0, 10.0);
        double uncertainty = uniform_range(0.0, 10.0);
        double representation = uniform_range(4.0, 9.5);
        double retrieval_latency = 80.0 + 26.0 * wm_load + 13.0 * uncertainty - 5.0 * representation;
        if (retrieval_latency < 10.0) retrieval_latency = 10.0;

        double accuracy = logistic(
            -0.75 +
            0.48 * representation -
            0.22 * uncertainty -
            0.14 * wm_load -
            0.0015 * retrieval_latency
        );

        if (wm_load > 7.0 && uncertainty > 6.0) overload_count++;

        latency_sum += retrieval_latency;
        accuracy_sum += accuracy;
    }

    printf("Trials: %d\n", n);
    printf("High memory/uncertainty overload cases: %d\n", overload_count);
    printf("Mean retrieval latency: %.3f ms\n", latency_sum / n);
    printf("Mean predicted accuracy: %.3f\n", accuracy_sum / n);

    return 0;
}
