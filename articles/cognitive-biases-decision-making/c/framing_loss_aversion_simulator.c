#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast framing and loss-aversion simulator.
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

static double subjective_value(double payoff, double lambda) {
    if (payoff >= 0.0) {
        return pow(payoff, 0.88);
    }
    return -lambda * pow(fabs(payoff), 0.88);
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) n = atoi(argv[1]);

    srand((unsigned int) time(NULL));

    double gain_risky = 0.0;
    double loss_risky = 0.0;
    int gain_n = 0;
    int loss_n = 0;

    for (int i = 0; i < n; i++) {
        int loss_frame = uniform01() < 0.5;
        double p = uniform_range(0.05, 0.95);
        double payoff = uniform_range(20.0, 800.0);
        if (loss_frame) payoff = -payoff;

        double lambda = uniform_range(1.5, 3.0);
        double sv = p * subjective_value(payoff, lambda);
        double risky_prob = logistic(-0.45 + 0.006 * sv + 1.25 * p - 0.25 * lambda * loss_frame);
        double chose_risky = uniform01() < risky_prob ? 1.0 : 0.0;

        if (loss_frame) {
            loss_risky += chose_risky;
            loss_n++;
        } else {
            gain_risky += chose_risky;
            gain_n++;
        }
    }

    printf("Trials: %d\n", n);
    printf("Gain-frame risky choice rate: %.3f\n", gain_risky / gain_n);
    printf("Loss-frame risky choice rate: %.3f\n", loss_risky / loss_n);
    printf("Framing difference: %.3f\n", (loss_risky / loss_n) - (gain_risky / gain_n));

    return 0;
}
