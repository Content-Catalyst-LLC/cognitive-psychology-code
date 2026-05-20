#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Fast learning-curve simulator.
 */

static double uniform01(void) {
    return (double) rand() / (double) RAND_MAX;
}

static double uniform_range(double min, double max) {
    return min + (max - min) * uniform01();
}

int main(int argc, char **argv) {
    int n = 10000;
    if (argc > 1) n = atoi(argv[1]);

    srand((unsigned int) time(NULL));

    double comprehension_sum = 0.0;
    double transfer_sum = 0.0;
    double retention_sum = 0.0;

    for (int i = 0; i < n; i++) {
        double session = uniform_range(1.0, 8.0);
        double prior = uniform_range(0.0, 10.0);
        double attention = uniform_range(0.0, 10.0);
        double retrieval = uniform01() < 0.5 ? 1.0 : 0.0;
        double feedback = uniform_range(0.0, 10.0);
        double load = uniform_range(0.0, 10.0);
        double schema = 3.0 + 0.35 * session + 0.20 * prior + 0.20 * attention + 0.4 * retrieval;

        if (schema > 10.0) schema = 10.0;

        double comprehension = 25.0 + 3.0 * attention + 2.5 * schema + 2.0 * feedback + 4.0 * retrieval - 2.0 * load;
        double transfer = 20.0 + 0.42 * comprehension + 2.5 * schema + 3.0 * retrieval - 1.6 * load;
        double retention = 22.0 + 0.40 * comprehension + 5.0 * retrieval + 1.8 * schema - 1.3 * load;

        if (comprehension < 0.0) comprehension = 0.0;
        if (comprehension > 100.0) comprehension = 100.0;
        if (transfer < 0.0) transfer = 0.0;
        if (transfer > 100.0) transfer = 100.0;
        if (retention < 0.0) retention = 0.0;
        if (retention > 100.0) retention = 100.0;

        comprehension_sum += comprehension;
        transfer_sum += transfer;
        retention_sum += retention;
    }

    printf("Trials: %d\n", n);
    printf("Mean comprehension score: %.3f\n", comprehension_sum / n);
    printf("Mean transfer score: %.3f\n", transfer_sum / n);
    printf("Mean retention score: %.3f\n", retention_sum / n);

    return 0;
}
