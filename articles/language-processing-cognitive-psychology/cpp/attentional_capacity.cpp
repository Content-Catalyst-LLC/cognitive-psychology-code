#include <iostream>
#include <vector>
#include <numeric>

int main() {
    std::vector<double> attention = {0.25, 0.30, 0.20};
    double capacity = 1.0;
    double total = std::accumulate(attention.begin(), attention.end(), 0.0);

    std::cout << "Total attentional allocation: " << total << "\n";
    std::cout << "Within capacity: " << (total <= capacity) << "\n";
    return 0;
}
