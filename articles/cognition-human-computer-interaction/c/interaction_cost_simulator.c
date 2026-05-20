#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight simulator for interaction cost and task success.
 *
 * C_total = perceptual + attentional + working_memory + decision_cost
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

    double cost_sum = 0.0;
    double success_sum = 0.0;
    double rt_sum = 0.0;
    int high_cost_count = 0;

    for (int i = 0; i < n; i++) {
        double perceptual = uniform_range(1.0, 9.0);
        double attention = uniform_range(1.0, 9.0);
        double memory = uniform_range(1.0, 9.0);
        double decision = uniform_range(1.0, 9.0);
        double alignment = uniform_range(2.0, 9.5);

        double cost = perceptual + attention + memory + decision - 0.75 * alignment;
        double success = logistic(2.3 - 0.22 * cost + 0.18 * alignment);
        double rt = exp(log(1800.0) + 0.055 * cost - 0.035 * alignment);

        if (cost > 22.0) high_cost_count++;

        cost_sum += cost;
        success_sum += success;
        rt_sum += rt;
    }

    printf("Trials: %d\n", n);
    printf("High-cost cases: %d\n", high_cost_count);
    printf("Mean interaction cost: %.3f\n", cost_sum / n);
    printf("Mean success probability: %.3f\n", success_sum / n);
    printf("Mean predicted response time: %.3f ms\n", rt_sum / n);

    return 0;
}
