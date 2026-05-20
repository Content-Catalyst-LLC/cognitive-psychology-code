#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast iconic-memory decay simulator.
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
    double trace_sum = 0.0;
    double report_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double delay_ms = uniform_range(0.0, 700.0);
        double s0 = uniform_range(0.80, 1.0);
        double lambda = uniform_range(0.0035, 0.0065);
        double trace = s0 * exp(-lambda * delay_ms);
        double salience = uniform_range(0.0, 10.0);
        double priority = uniform_range(0.0, 10.0);
        double mask = uniform01() < 0.25 ? 1.0 : 0.0;

        if (mask > 0.0) trace *= 0.55;

        double p_correct = logistic(-1.2 + 3.1 * trace + 0.18 * salience + 0.28 * priority - 0.45 * mask);
        double report = 1.0 + 3.0 * p_correct + 0.15 * priority;

        trace_sum += trace;
        accuracy_sum += p_correct;
        report_sum += report;
    }

    printf("Trials: %d\n", n);
    printf("Mean trace strength: %.3f\n", trace_sum / n);
    printf("Mean correct-report probability: %.3f\n", accuracy_sum / n);
    printf("Mean report estimate: %.3f\n", report_sum / n);

    return 0;
}
