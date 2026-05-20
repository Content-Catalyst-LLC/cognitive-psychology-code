#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Lightweight relational-fit simulator for analogical reasoning research.
 *
 * Mapping probability increases with structural similarity and source familiarity,
 * and decreases with relational complexity and working-memory burden.
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

    double mapping_sum = 0.0;
    double transfer_sum = 0.0;
    double quality_sum = 0.0;
    int misleading_surface_cases = 0;

    for (int i = 0; i < n; i++) {
        double surface = uniform_range(0.0, 10.0);
        double structure = uniform_range(0.0, 10.0);
        double complexity = uniform_range(0.0, 10.0);
        double familiarity = uniform_range(0.0, 10.0);
        double wm = uniform_range(0.0, 10.0);
        double cue = uniform01() < 0.40 ? 1.0 : 0.0;

        double mapping_p = logistic(-2.0 + 0.55 * structure + 0.20 * familiarity + 0.55 * cue - 0.30 * complexity - 0.18 * wm);
        double transfer_p = logistic(-2.4 + 0.62 * structure + 0.70 * mapping_p + 0.40 * cue - 0.28 * complexity - 0.18 * wm);
        double quality = 35.0 + 5.0 * structure + 8.0 * mapping_p + 9.0 * transfer_p - 2.0 * complexity - 1.0 * wm;

        if (quality < 0.0) quality = 0.0;
        if (quality > 100.0) quality = 100.0;

        if (surface > 7.0 && structure < 4.5) misleading_surface_cases++;

        mapping_sum += mapping_p;
        transfer_sum += transfer_p;
        quality_sum += quality;
    }

    printf("Trials: %d\n", n);
    printf("Misleading high-surface/low-structure cases: %d\n", misleading_surface_cases);
    printf("Mean mapping probability: %.3f\n", mapping_sum / n);
    printf("Mean transfer probability: %.3f\n", transfer_sum / n);
    printf("Mean inference quality: %.3f\n", quality_sum / n);

    return 0;
}
