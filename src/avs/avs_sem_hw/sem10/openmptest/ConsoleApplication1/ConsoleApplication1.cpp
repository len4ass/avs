// c++ main.cpp -fopenmp
//#include <cmath>
#include <functional>
#include <iostream>
#include <omp.h>

double rectIntegral(
    const std::function<double(double)>& fun,
    const double a, const double b, const int n)
{
    double h = std::abs((b - a) / n);
    double sum = 0;

    ///#pragma omp parallel num_threads(1000) reduction (+: sum)
    ///#pragma omp parallel num_threads(100) reduction (+: sum)
    ///#pragma omp parallel num_threads(1) reduction (+: sum)
    ///#pragma omp parallel num_threads(2) reduction (+: sum)
#pragma omp parallel num_threads(6) reduction (+: sum)
    ///#pragma omp parallel reduction (+: sum)
    {
#pragma omp for 
        for (int i = 0; i < n; ++i) {
            sum += fun(a + i * h) * h;
        }
#pragma omp critical
        {
            std::cout << omp_get_thread_num() << ": sum = " << sum << "\n";
        }
    }  // pragma omp parallel
    return sum;
}

double fTest(double x) {
    return 0.5 * x;
}

int main() {
    auto integralValie = rectIntegral(fTest, 0, 5, 10000000);
    std::cout << "Integral value = " << integralValie << "\n";

    auto integralValie2 = rectIntegral([](double x)->double { return 0.01 * x; }, 0, 5, 10000000);
    std::cout << "Integral value = " << integralValie2 << "\n";

    return 0;
}
