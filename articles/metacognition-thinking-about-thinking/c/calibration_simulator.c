#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight calibration simulator.
 *
 * Simulates confidence, actual accuracy, calibration error,
 * and strategy shift as a function of task difficulty and evidence quality.
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

    double accuracy_sum = 0.0;
    double confidence_sum = 0.0;
    double calibration_sum = 0.0;
    double shift_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double difficulty = uniform_range(0.0, 10.0);
        double evidence = uniform_range(0.0, 10.0);
        double skill = uniform_range(-1.0, 1.0);

        double accuracy_p = logistic(0.2 + 0.25 * evidence - 0.32 * difficulty + 0.40 * skill);
        double accuracy = uniform01() < accuracy_p ? 1.0 : 0.0;

        double confidence = 0.48 + 0.26 * accuracy - 0.030 * difficulty + 0.020 * evidence + 0.08 * skill;
        if (confidence < 0.0) confidence = 0.0;
        if (confidence > 1.0) confidence = 1.0;

        double uncertainty = 1.0 - confidence;
        double calibration_error = fabs(confidence - accuracy);
        double shift_p = logistic(-1.2 + 1.7 * uncertainty + 0.18 * difficulty - 1.1 * confidence + 0.25 * skill);

        accuracy_sum += accuracy;
        confidence_sum += confidence;
        calibration_sum += calibration_error;
        shift_sum += shift_p;
    }

    printf("Trials: %d\n", n);
    printf("Accuracy rate: %.3f\n", accuracy_sum / n);
    printf("Mean confidence: %.3f\n", confidence_sum / n);
    printf("Mean calibration error: %.3f\n", calibration_sum / n);
    printf("Mean strategy-shift probability: %.3f\n", shift_sum / n);

    return 0;
}
