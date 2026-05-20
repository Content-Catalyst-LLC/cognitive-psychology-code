#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight prospect-theory value simulator.
 *
 * v(x) = x^alpha for gains
 * v(x) = -lambda * (-x)^beta for losses
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

static double prospect_value(double x, double alpha, double beta, double lambda) {
    if (x >= 0.0) {
        return pow(x, alpha);
    }
    return -lambda * pow(-x, beta);
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

    double value_sum = 0.0;
    double risky_sum = 0.0;
    double lambda_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double gain_domain = uniform01() < 0.5;
        double amount = uniform_range(10.0, 250.0);
        if (!gain_domain) amount = -amount;

        double probability = uniform_range(0.05, 0.95);
        double cognitive_load = uniform_range(0.0, 10.0);
        double lambda = uniform_range(1.4, 3.2);

        double value = prospect_value(amount, 0.88, 0.88, lambda);
        double risky_prob = logistic(-0.75 + 0.018 * value + 0.90 * probability - 0.10 * cognitive_load + (!gain_domain ? 0.55 : 0.0));

        value_sum += value;
        risky_sum += risky_prob;
        lambda_sum += lambda;
    }

    printf("Trials: %d\n", n);
    printf("Mean prospect value: %.3f\n", value_sum / n);
    printf("Mean risky-choice probability: %.3f\n", risky_sum / n);
    printf("Mean loss-aversion lambda: %.3f\n", lambda_sum / n);

    return 0;
}
