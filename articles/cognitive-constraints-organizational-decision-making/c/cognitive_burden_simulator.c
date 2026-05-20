#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight Monte Carlo simulation of organizational cognitive burden.
 *
 * burden = I + U + C + P + 0.5F + 0.25A - 0.55S - 0.9D
 *
 * where:
 * I = information load
 * U = uncertainty
 * C = coordination load
 * P = institutional pressure
 * F = feedback delay
 * A = automation reliance
 * S = psychological safety
 * D = dissent present
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) {
        n = atoi(argv[1]);
    }

    srand((unsigned int) time(NULL));

    int overload_count = 0;
    int high_risk_count = 0;
    double burden_sum = 0.0;
    double quality_sum = 0.0;

    for (int i = 0; i < n; i++) {
        int overload = uniform01() < 0.5;

        double info = overload ? uniform_range(6.5, 10.0) : uniform_range(2.0, 6.0);
        double uncertainty = overload ? uniform_range(6.0, 10.0) : uniform_range(2.0, 6.0);
        double coordination = overload ? uniform_range(5.5, 10.0) : uniform_range(2.0, 6.0);
        double pressure = overload ? uniform_range(5.5, 10.0) : uniform_range(2.0, 6.5);
        double delay = overload ? uniform_range(5.0, 10.0) : uniform_range(1.0, 5.0);
        double automation = overload ? uniform_range(4.0, 9.0) : uniform_range(1.0, 6.0);
        double safety = overload ? uniform_range(2.0, 6.0) : uniform_range(5.0, 9.5);
        double dissent = uniform01() < (0.20 + 0.07 * safety) ? 1.0 : 0.0;

        double burden = info + uncertainty + coordination + pressure +
                        0.5 * delay + 0.25 * automation -
                        0.55 * safety - 0.9 * dissent;

        double quality = 95.0 - 2.2 * burden + 1.4 * safety + 2.5 * dissent;
        if (quality < 0.0) quality = 0.0;
        if (quality > 100.0) quality = 100.0;

        if (overload) overload_count++;
        if (burden > 22.0 && quality < 60.0) high_risk_count++;

        burden_sum += burden;
        quality_sum += quality;
    }

    printf("Trials: %d\n", n);
    printf("Overload trials: %d\n", overload_count);
    printf("High-risk burden/quality cases: %d\n", high_risk_count);
    printf("Mean cognitive burden: %.3f\n", burden_sum / n);
    printf("Mean decision quality: %.3f\n", quality_sum / n);

    return 0;
}
