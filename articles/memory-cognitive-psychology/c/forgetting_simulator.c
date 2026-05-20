#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double uniform01(void) { return (double) rand() / (double) RAND_MAX; }
static double range(double a, double b) { return a + (b - a) * uniform01(); }
static double logistic(double x) { if (x > 40) return 1; if (x < -40) return 0; return 1 / (1 + exp(-x)); }

int main(int argc, char **argv) {
    int n = argc > 1 ? atoi(argv[1]) : 10000;
    srand((unsigned int) time(NULL));
    double exp_sum = 0, power_sum = 0, correct_sum = 0;
    for (int i = 0; i < n; i++) {
        double delay = range(0.25, 30), initial = range(0.55, 1.25), lambda = range(0.03, 0.18);
        double interference = range(0, 10), cue = range(0, 10);
        double exp_ret = initial * exp(-lambda * delay);
        double power_ret = initial * pow(delay + 1, -0.22);
        double p = logistic(-1.6 + 2.5 * exp_ret + 0.16 * cue - 0.20 * interference);
        exp_sum += exp_ret; power_sum += power_ret; correct_sum += uniform01() < p ? 1 : 0;
    }
    printf("Trials: %d\nMean exponential retention: %.3f\nMean power-law retention: %.3f\nCorrect retrieval rate: %.3f\n", n, exp_sum/n, power_sum/n, correct_sum/n);
    return 0;
}
