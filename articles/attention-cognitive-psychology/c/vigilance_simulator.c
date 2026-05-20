#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double uniform01(void) { return (double) rand() / (double) RAND_MAX; }
static double uniform_range(double min, double max) { return min + (max - min) * uniform01(); }
static double logistic(double x) {
    if (x > 40.0) return 1.0;
    if (x < -40.0) return 0.0;
    return 1.0 / (1.0 + exp(-x));
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) n = atoi(argv[1]);
    srand((unsigned int) time(NULL));

    double correct_sum = 0.0;
    double rt_sum = 0.0;
    double lapse_sum = 0.0;

    for (int i = 0; i < n; i++) {
        int block = 1 + rand() % 8;
        int target = uniform01() < 0.30 ? 1 : 0;
        double salience = uniform_range(2.0, 9.0);
        double load = uniform_range(1.0, 9.0);
        double vigilance = fmax(0.0, fmin(10.0, 8.2 - 0.45 * block - 0.20 * load + uniform_range(-1.0, 1.0)));
        double lapse = logistic(-2.6 + 0.34 * block + 0.22 * load - 0.30 * vigilance);
        double evidence = 0.50 * salience + 0.80 * target - 0.25 * load - 1.2 * lapse;
        double p_yes = logistic(evidence);
        int response = uniform01() < p_yes ? 1 : 0;
        int correct = response == target ? 1 : 0;
        double rt = exp(log(720.0) + 0.05 * block + 0.04 * load - 0.03 * salience + 0.18 * (1 - correct));

        correct_sum += correct;
        rt_sum += rt;
        lapse_sum += lapse;
    }

    printf("Trials: %d\n", n);
    printf("Correct rate: %.3f\n", correct_sum / n);
    printf("Mean RT ms: %.3f\n", rt_sum / n);
    printf("Mean lapse probability: %.3f\n", lapse_sum / n);
    return 0;
}
