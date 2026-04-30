#include <stdio.h>

double adjusted_reaction_time(double base_ms, double load, double penalty_ms) {
    return base_ms + load * penalty_ms;
}

int main(void) {
    printf("Adjusted reaction time: %.2f ms\n", adjusted_reaction_time(500.0, 0.75, 120.0));
    return 0;
}
