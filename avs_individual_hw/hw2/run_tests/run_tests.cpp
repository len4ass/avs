#include <iostream>
#include <chrono>
#include <vector>

extern "C" {
    // Asm self coded function
    char *find_sequence(const char* string, int64_t size, int64_t sequence_len);

    // Standard C function
    char *find_sequence_standard(const char* string, int64_t size, int64_t sequence_len);

    // Compiled with -O0 C function
    char *find_sequence_O0(const char* string, int64_t size, int64_t sequence_len);

    // Compiled with -O1 C function
    char *find_sequence_O1(const char* string, int64_t size, int64_t sequence_len);

    // Compiled with -O2 C function
    char *find_sequence_O2(const char* string, int64_t size, int64_t sequence_len);

    // Compiled with -O3 C function
    char *find_sequence_O3(const char* string, int64_t size, int64_t sequence_len);

    // Compiled with -Ofast C function
    char *find_sequence_Ofast(const char* string, int64_t size, int64_t sequence_len);
}

char *generate_string(int64_t size) {
    time_t unix_time = time(nullptr);
    srand(unix_time);

    char *string = (char*)malloc(size + 1);
    int64_t random_val;
    for (int64_t i = 0; i < size; ++i) {
        random_val = abs(rand());
        random_val = 32 + (random_val % 95);
        string[i] = (char)random_val;
    }

    string[size] = '\0';
    return string;
}

double time_exec(char* (*func) (const char* s, int64_t sz, int64_t sq_len), const char *s, int64_t sz, int64_t sq_len) {
    auto start = std::chrono::steady_clock::now();
    char* seq = func(s, sz, sq_len);
    auto end = std::chrono::steady_clock::now();

    if (seq != nullptr) {
        free(seq);
    }
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

void test(int64_t sz, int64_t sq_len, int64_t tests) {
    char *string = generate_string(sz);

    std::cout << "GENERATED STRING, SIZE=" << sz << "\nLOOKING FOR SEQUENCE, LEN=" << sq_len << "\nTESTING " << tests << " TIMES..." << std::endl;
    std::vector<double> st;
    std::vector<double> o0;
    std::vector<double> o1;
    std::vector<double> o2;
    std::vector<double> o3;
    std::vector<double> ofast;
    std::vector<double> self_asm;

    for (int64_t i = 0; i < tests; ++i) {
        // Повышаем частоту процессора
        time_exec(find_sequence_standard, string, sz, sq_len);

        st.push_back(time_exec(find_sequence_standard, string, sz, sq_len));
        o0.push_back(time_exec(find_sequence_O0, string, sz, sq_len));
        o1.push_back(time_exec(find_sequence_O1, string, sz, sq_len));
        o2.push_back(time_exec(find_sequence_O2, string, sz, sq_len));
        o3.push_back(time_exec(find_sequence_O3, string, sz, sq_len));
        ofast.push_back(time_exec(find_sequence_Ofast, string, sz, sq_len));
        self_asm.push_back(time_exec(find_sequence, string, sz, sq_len));

        // Превентивная мера, предотвращаем спад частоты на последнем тесте
        time_exec(find_sequence_standard, string, sz, sq_len);
    }
    free(string);

    auto [st_avg, st_dev] = get_avg_and_deviation(st);
    auto [o0_avg, o0_dev] = get_avg_and_deviation(o0);
    auto [o1_avg, o1_dev] = get_avg_and_deviation(o1);
    auto [o2_avg, o2_dev] = get_avg_and_deviation(o2);
    auto [o3_avg, o3_dev] = get_avg_and_deviation(o3);
    auto [ofast_avg, ofast_dev] = get_avg_and_deviation(ofast);
    auto [asm_avg, asm_dev] = get_avg_and_deviation(self_asm);

    std::cout << "Sequence find standard average: " << st_avg << " ms" << " (deviation " << st_dev << "%)" << std::endl;
    std::cout << "Sequence find -O0 average: " << o0_avg << " ms" << " (deviation " << o0_dev << "%)" << std::endl;
    std::cout << "Sequence find -01 average: " << o1_avg << " ms" << " (deviation " << o1_dev << "%)" << std::endl;
    std::cout << "Sequence find -O2 average: " << o2_avg << " ms" << " (deviation " << o2_dev << "%)" << std::endl;
    std::cout << "Sequence find -O3 average: " << o3_avg << " ms" << " (deviation " << o3_dev << "%)" << std::endl;
    std::cout << "Sequence find -Ofast average: " << ofast_avg << " ms" << " (deviation " << ofast_dev << "%)" << std::endl;
    std::cout << "Self coded asm sequence find average: " << asm_avg << " ms" << " (deviation " << asm_dev << "%)" << std::endl;
    std::cout << std::endl;
}

#pragma optimize("", off)
int main() {
    // Размер 1 миллион, ищем последовательность из 10 символов, 25 тестов
    test(1000000, 10, 25);

    // Размер 10 миллионов, ищем последовательность из 25 символов, 10 тестов
    test(10000000, 25, 10);

    // Размер 100 миллионов, ищем последовательность из 50 символов, 5 тестов
    test(100000000, 50, 5);

    // Максимальный размер 2 гигабайта -> 2 * 1073741824 байт (не рекомендуется)
    return 0;
}

