#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast expected-utility and satisficing simulator.
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

static double utility(double payoff, double lambda) {
    if (payoff >= 0.0) return pow(payoff, 0.88);
    return -lambda * pow(fabs(payoff), 0.88);
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) n = atoi(argv[1]);

    srand((unsigned int) time(NULL));

    double optimizing_quality_sum = 0.0;
    double satisficing_quality_sum = 0.0;
    double optimizing_search_sum = 0.0;
    double satisficing_search_sum = 0.0;

    for (int i = 0; i < n; i++) {
        int options = 2 + rand() % 8;
        double lambda = uniform_range(1.4, 3.0);
        double aspiration = uniform_range(20.0, 120.0);

        double best_u = -1e9;
        double first_satisfactory_u = -1e9;
        int satisficing_steps = options;

        for (int j = 0; j < options; j++) {
            double p = uniform_range(0.05, 0.95);
            double payoff = uniform_range(-600.0, 900.0);
            double eu = p * utility(payoff, lambda);

            if (eu > best_u) best_u = eu;

            if (first_satisfactory_u < -1e8 && eu >= aspiration) {
                first_satisfactory_u = eu;
                satisficing_steps = j + 1;
            }
        }

        if (first_satisfactory_u < -1e8) first_satisfactory_u = best_u;

        optimizing_quality_sum += best_u;
        satisficing_quality_sum += first_satisfactory_u;
        optimizing_search_sum += options;
        satisficing_search_sum += satisficing_steps;
    }

    printf("Trials: %d\n", n);
    printf("Mean optimizing utility: %.3f\n", optimizing_quality_sum / n);
    printf("Mean satisficing utility: %.3f\n", satisficing_quality_sum / n);
    printf("Mean optimizing search steps: %.3f\n", optimizing_search_sum / n);
    printf("Mean satisficing search steps: %.3f\n", satisficing_search_sum / n);

    return 0;
}
