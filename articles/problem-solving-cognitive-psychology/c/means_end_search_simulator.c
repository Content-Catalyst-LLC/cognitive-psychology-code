#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight means-end search simulator.
 *
 * A solver attempts to reduce distance from current state to goal state.
 * Representation quality, operator quality, and working-memory load shape
 * the probability of selecting useful moves.
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

    double success_sum = 0.0;
    double quality_sum = 0.0;
    double search_cost_sum = 0.0;
    int high_load_cases = 0;

    for (int i = 0; i < n; i++) {
        double difficulty = uniform_range(0.0, 10.0);
        double representation = uniform_range(0.0, 10.0);
        double wm = uniform_range(0.0, 10.0);
        double constraint = uniform_range(0.0, 10.0);
        double metacognition = uniform_range(0.0, 10.0);

        double useful_move_p = logistic(-1.2 + 0.35 * representation + 0.18 * metacognition - 0.20 * wm - 0.15 * constraint);
        double search_cost = 1.0 + difficulty + 0.7 * wm + 0.5 * constraint - 0.4 * representation;

        double success_p = logistic(-2.1 + 0.42 * representation + 0.24 * metacognition + 0.65 * useful_move_p - 0.28 * difficulty - 0.22 * wm);
        double quality = 35.0 + 5.0 * representation + 2.5 * metacognition + 8.0 * success_p - 2.2 * difficulty - 1.4 * wm;

        if (quality < 0.0) quality = 0.0;
        if (quality > 100.0) quality = 100.0;

        if (wm > 8.0) high_load_cases++;

        success_sum += success_p;
        quality_sum += quality;
        search_cost_sum += search_cost;
    }

    printf("Trials: %d\n", n);
    printf("High working-memory load cases: %d\n", high_load_cases);
    printf("Mean success probability: %.3f\n", success_sum / n);
    printf("Mean solution quality: %.3f\n", quality_sum / n);
    printf("Mean search cost: %.3f\n", search_cost_sum / n);

    return 0;
}
