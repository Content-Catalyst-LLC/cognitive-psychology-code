#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast risk-weighting simulator.
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

static double prelec_weight(double p, double gamma) {
    if (p < 1e-6) p = 1e-6;
    if (p > 1.0 - 1e-6) p = 1.0 - 1e-6;
    return exp(-pow(-log(p), gamma));
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

    double distortion_sum = 0.0;
    double risk_sum = 0.0;
    double safe_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double p = uniform_range(0.001, 0.75);
        double gamma = uniform_range(0.55, 0.90);
        double weighted_p = prelec_weight(p, gamma);
        double consequence = uniform_range(0.0, 10.0);
        double affect = uniform_range(0.0, 10.0);
        double dread = uniform_range(0.0, 10.0);
        double controllability = uniform_range(0.0, 10.0);
        double benefit = uniform_range(0.0, 10.0);

        double perceived_risk = 1.0 + 5.5 * weighted_p + 0.35 * consequence + 0.30 * affect + 0.24 * dread - 0.18 * controllability - 0.10 * benefit;
        if (perceived_risk < 0.0) perceived_risk = 0.0;
        if (perceived_risk > 10.0) perceived_risk = 10.0;

        double safe_p = logistic(-2.6 + 0.45 * perceived_risk + 0.18 * consequence + 0.14 * affect - 0.10 * benefit);

        distortion_sum += weighted_p - p;
        risk_sum += perceived_risk;
        safe_sum += safe_p;
    }

    printf("Trials: %d\n", n);
    printf("Mean probability distortion: %.4f\n", distortion_sum / n);
    printf("Mean perceived risk: %.3f\n", risk_sum / n);
    printf("Mean safe-choice probability: %.3f\n", safe_sum / n);

    return 0;
}
