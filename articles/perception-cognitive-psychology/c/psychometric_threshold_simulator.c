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

    double yes_sum = 0.0;
    double correct_sum = 0.0;
    double threshold_sum = 0.0;

    for (int i = 0; i < n; i++) {
        int signal = uniform01() < 0.55 ? 1 : 0;
        double stimulus = uniform_range(-3.0, 3.0) + 1.0 * signal;
        double threshold = uniform_range(-0.5, 1.5);
        double noise = uniform_range(0.5, 4.0);
        double evidence = stimulus - threshold - 0.20 * noise;
        double p_yes = logistic(1.2 * evidence);
        int response = uniform01() < p_yes ? 1 : 0;
        int correct = (signal == response) ? 1 : 0;
        yes_sum += response;
        correct_sum += correct;
        threshold_sum += threshold;
    }

    printf("Trials: %d\n", n);
    printf("Yes response rate: %.3f\n", yes_sum / n);
    printf("Correct rate: %.3f\n", correct_sum / n);
    printf("Mean threshold: %.3f\n", threshold_sum / n);
    return 0;
}
