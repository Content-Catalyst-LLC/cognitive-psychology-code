#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast anchoring and adjustment simulator.
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

    double high_sum = 0.0;
    double low_sum = 0.0;
    double high_bias_sum = 0.0;
    double low_bias_sum = 0.0;
    int high_n = 0;
    int low_n = 0;

    for (int i = 0; i < n; i++) {
        double true_value = uniform_range(10.0, 90.0);
        int high_anchor = uniform01() < 0.5;
        double anchor = true_value + (high_anchor ? 25.0 : -25.0) + uniform_range(-8.0, 8.0);
        if (anchor < 0.0) anchor = 0.0;
        if (anchor > 100.0) anchor = 100.0;

        double susceptibility = uniform_range(0.25, 0.75);
        double adjustment = (true_value - anchor) * (1.0 - susceptibility);
        double estimate = anchor + adjustment + uniform_range(-6.0, 6.0);
        if (estimate < 0.0) estimate = 0.0;
        if (estimate > 100.0) estimate = 100.0;

        double bias = estimate - true_value;

        if (high_anchor) {
            high_sum += estimate;
            high_bias_sum += bias;
            high_n++;
        } else {
            low_sum += estimate;
            low_bias_sum += bias;
            low_n++;
        }
    }

    printf("Trials: %d\n", n);
    printf("Mean high-anchor estimate: %.3f\n", high_sum / high_n);
    printf("Mean low-anchor estimate: %.3f\n", low_sum / low_n);
    printf("Anchoring effect: %.3f\n", (high_sum / high_n) - (low_sum / low_n));
    printf("Mean high-anchor bias: %.3f\n", high_bias_sum / high_n);
    printf("Mean low-anchor bias: %.3f\n", low_bias_sum / low_n);

    return 0;
}
