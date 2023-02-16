#include <iostream>
#include <chrono>
#include <vector>

extern "C" {
    // Asm self coded function
    int64_t *transform_array(int64_t *a1, int64_t a2);

    // Standard C function
    int64_t *transform_array_standard(int64_t *a1, int64_t a2);

    // Compiled with -O0 C function
    int64_t *transform_array_O0(int64_t *a1, int64_t a2);

    // Compiled with -O1 C function
    int64_t *transform_array_O1(int64_t *a1, int64_t a2);

    // Compiled with -O2 C function
    int64_t *transform_array_O2(int64_t *a1, int64_t a2);

    // Compiled with -O3 C function
    int64_t *transform_array_O3(int64_t *a1, int64_t a2);

    // Compiled with -Ofast C function
    int64_t *transform_array_Ofast(int64_t *a1, int64_t a2);
}

int64_t* generate_array(int64_t size) {
    time_t unix_time = time(nullptr);
    srand(unix_time);

    int64_t *array = (int64_t*)malloc(size * 8);
    for (int64_t i = 0; i < size; ++i) {
        array[i] = rand();
    }

    return array;
}

double time_exec(int64_t* (*func) (int64_t *array, int64_t size), int64_t *array, int64_t size) {
    auto start = std::chrono::steady_clock::now();
    int64_t* new_array = func(array, size);
    auto end = std::chrono::steady_clock::now();
    free(new_array);
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

void test(int64_t sz, int64_t tests) {
    int64_t *array = generate_array(sz);

    std::cout << "GENERATED ARRAY, SIZE=" << sz << ", TESTING " << tests << " TIMES..." << std::endl;
    std::vector<double> st;
    std::vector<double> o0;
    std::vector<double> o1;
    std::vector<double> o2;
    std::vector<double> o3;
    std::vector<double> ofast;
    std::vector<double> self_asm;

    for (int64_t i = 0; i < tests; ++i) {
        // Повышаем частоту процессора
        time_exec(transform_array_standard, array, sz);

        st.push_back(time_exec(transform_array_standard, array, sz));
        o0.push_back(time_exec(transform_array_O0, array, sz));
        o1.push_back(time_exec(transform_array_O1, array, sz));
        o2.push_back(time_exec(transform_array_O2, array, sz));
        o3.push_back(time_exec(transform_array_O3, array, sz));
        ofast.push_back(time_exec(transform_array_Ofast, array, sz));
        self_asm.push_back(time_exec(transform_array, array, sz));

        // Превентивная мера, предотвращаем спад частоты на последнем тесте
        time_exec(transform_array_standard, array, sz);
    }
    free(array);

    auto [st_avg, st_dev] = get_avg_and_deviation(st);
    auto [o0_avg, o0_dev] = get_avg_and_deviation(o0);
    auto [o1_avg, o1_dev] = get_avg_and_deviation(o1);
    auto [o2_avg, o2_dev] = get_avg_and_deviation(o2);
    auto [o3_avg, o3_dev] = get_avg_and_deviation(o3);
    auto [ofast_avg, ofast_dev] = get_avg_and_deviation(ofast);
    auto [asm_avg, asm_dev] = get_avg_and_deviation(self_asm);

    std::cout << "Array transform standard average: " << st_avg << " ms" << " (deviation " << st_dev << "%)" << std::endl;
    std::cout << "Array transform -O0 average: " << o0_avg << " ms" << " (deviation " << o0_dev << "%)" << std::endl;
    std::cout << "Array transform -01 average: " << o1_avg << " ms" << " (deviation " << o1_dev << "%)" << std::endl;
    std::cout << "Array transform -O2 average: " << o2_avg << " ms" << " (deviation " << o2_dev << "%)" << std::endl;
    std::cout << "Array transform -O3 average: " << o3_avg << " ms" << " (deviation " << o3_dev << "%)" << std::endl;
    std::cout << "Array transform -Ofast average: " << ofast_avg << " ms" << " (deviation " << ofast_dev << "%)" << std::endl;
    std::cout << "Self coded asm array transform average: " << asm_avg << " ms" << " (deviation " << asm_dev << "%)" << std::endl;
    std::cout << std::endl;
}

#pragma optimize("", off)
int main() {
    // Размер 50 миллионов, 25 тестов
    test(50000000, 25);

    // Размер 100 миллионов, 10 тестов
    test(100000000, 10);

    // Размер 250 миллионов, 5 тестов
    test(250000000, 5);

    // 268435456 максимальный размер
    return 0;
}

