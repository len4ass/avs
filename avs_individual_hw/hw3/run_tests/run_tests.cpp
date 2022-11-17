#include <iostream>
#include <chrono>
#include <vector>

extern "C" {
    // Asm self coded function
    double integrate(double a, double b, double lower_bound, double upper_bound);

    // Standard C function
    double integrate_standard(double a, double b, double lower_bound, double upper_bound);

    // Compiled with -O0 C function
    double integrate_O0(double a, double b, double lower_bound, double upper_bound);

    // Compiled with -O1 C function
    double integrate_O1(double a, double b, double lower_bound, double upper_bound);

    // Compiled with -O2 C function
    double integrate_O2(double a, double b, double lower_bound, double upper_bound);

    // Compiled with -O3 C function
    double integrate_O3(double a, double b, double lower_bound, double upper_bound);

    // Compiled with -Ofast C function
    double integrate_Ofast(double a, double b, double lower_bound, double upper_bound);
}

double generate_double(double lower_bound, double upper_bound) {
    double range = upper_bound - lower_bound;
    double div = RAND_MAX / range;
    return lower_bound + (rand() / div);
}

double time_exec(double (*func) (double a, double b, double l, double u), double a, double b, double l, double u) {
    auto start = std::chrono::steady_clock::now();
    func(a, b, l, u);
    auto end = std::chrono::steady_clock::now();

    auto milliseconds = std::chrono::duration<double, std::milli>(end - start).count();
    return milliseconds;
}

std::pair<double, double> get_avg_and_deviation(const std::vector<double>& v) {
    double max = 0;
    double sum = 0;
    for (auto i : v) {
        if (i >= max) {
            max = i;
        }

        sum += i;
    }

    double avg = sum / (double)v.size();
    double deviation_percent = ((max - avg) / max) * 100;
    return std::make_pair(avg, deviation_percent);
}

void test(double lower_bound, double upper_bound, size_t tests) {
    srand(time(nullptr));
    double a = generate_double(1, 100);
    double b = generate_double(1, 100);

    std::cout << "GENERATED FUNCTION, a=" << a << "; b=" << b << "\nINTEGRATING FROM " << lower_bound << " TO " << upper_bound << "\n";
    std::cout << "TESTING " << tests << " TIMES..." << std::endl;
    std::vector<double> st;
    std::vector<double> o0;
    std::vector<double> o1;
    std::vector<double> o2;
    std::vector<double> o3;
    std::vector<double> ofast;
    std::vector<double> self_asm;

    for (int64_t i = 0; i < tests; ++i) {
        // Повышаем частоту процессора
        time_exec(integrate_standard, a, b, lower_bound, upper_bound);

        st.push_back(time_exec(integrate_standard, a, b, lower_bound, upper_bound));
        o0.push_back(time_exec(integrate_O0, a, b, lower_bound, upper_bound));
        o1.push_back(time_exec(integrate_O1, a, b, lower_bound, upper_bound));
        o2.push_back(time_exec(integrate_O2, a, b, lower_bound, upper_bound));
        o3.push_back(time_exec(integrate_O3, a, b, lower_bound, upper_bound));
        ofast.push_back(time_exec(integrate_Ofast, a, b, lower_bound, upper_bound));
        self_asm.push_back(time_exec(integrate, a, b, lower_bound, upper_bound));

        // Превентивная мера, предотвращаем спад частоты на последнем тесте
        time_exec(integrate_standard, a, b, lower_bound, upper_bound);
    }

    auto [st_avg, st_dev] = get_avg_and_deviation(st);
    auto [o0_avg, o0_dev] = get_avg_and_deviation(o0);
    auto [o1_avg, o1_dev] = get_avg_and_deviation(o1);
    auto [o2_avg, o2_dev] = get_avg_and_deviation(o2);
    auto [o3_avg, o3_dev] = get_avg_and_deviation(o3);
    auto [ofast_avg, ofast_dev] = get_avg_and_deviation(ofast);
    auto [asm_avg, asm_dev] = get_avg_and_deviation(self_asm);

    std::cout << "Integrate standard average: " << st_avg << " ms" << " (deviation " << st_dev << "%)" << std::endl;
    std::cout << "Integrate -O0 average: " << o0_avg << " ms" << " (deviation " << o0_dev << "%)" << std::endl;
    std::cout << "Integrate -01 average: " << o1_avg << " ms" << " (deviation " << o1_dev << "%)" << std::endl;
    std::cout << "Integrate -O2 average: " << o2_avg << " ms" << " (deviation " << o2_dev << "%)" << std::endl;
    std::cout << "Integrate -O3 average: " << o3_avg << " ms" << " (deviation " << o3_dev << "%)" << std::endl;
    std::cout << "Integrate -Ofast average: " << ofast_avg << " ms" << " (deviation " << ofast_dev << "%)" << std::endl;
    std::cout << "Self coded asm integrate average: " << asm_avg << " ms" << " (deviation " << asm_dev << "%)" << std::endl;
    std::cout << std::endl;
}

#pragma optimize("", off)
int main() {
    // Промежуток 1000, кол-во разбиений 1000000, 25 тестов
    test(10, 1010, 25);

    // Промежуток 10000, кол-во разбиений 10000000, 10 тестов
    test(10, 10010, 10);

    // Промежуток 100000, кол-во разбиений 100000000, 5 тестов
    test(10, 100010, 5);

    return 0;
}

