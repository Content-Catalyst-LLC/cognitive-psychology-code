#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast span-capacity simulator.
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

    double accuracy_sum = 0.0;
    double overload_sum = 0.0;
    double span_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double capacity = uniform_range(2.0, 7.0);
        int load = 1 + rand() % 10;
        double interference = uniform_range(0.0, 10.0);
        double attentional_control = uniform_range(3.0, 9.0);
        double overload = load > capacity ? load - capacity : 0.0;
        double overload_probability = logistic(-1.8 + 0.75 * overload + 0.15 * interference - 0.12 * attentional_control);
        double accuracy = logistic(2.0 + 0.55 * capacity - 0.55 * load - 0.22 * interference + 0.18 * attentional_control);

        accuracy_sum += accuracy;
        overload_sum += overload_probability;
        span_sum += capacity;
    }

    printf("Trials: %d\n", n);
    printf("Mean accuracy: %.3f\n", accuracy_sum / n);
    printf("Mean overload probability: %.3f\n", overload_sum / n);
    printf("Mean capacity estimate: %.3f\n", span_sum / n);

    return 0;
}
