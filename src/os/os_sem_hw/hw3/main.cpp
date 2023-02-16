#include <iostream>
#include <stdlib.h>
#include <unistd.h>

int64_t factorial(int64_t n) {
    int64_t factorial = 1;
    for (int64_t i = 2; i <= n; ++i) {
        factorial *= i;
    }

    return factorial;
}

int64_t fibonacci(int64_t n) {
    int64_t f = 0;
    int64_t s = 1;
    if (n == 0) {
        return f;
    }

    if (n == 1) {
        return s;
    }

    int64_t result = f + s;
    for (int64_t i = 3; i <= n; ++i) {
        f = s;
        s = result;
        result = f + s;
    }

    return result;
}

int main(int argc, char** argv) {
    int n;
    scanf("%d", &n);
    printf("Input - %d\n", n);
    pid_t chpid = fork();
    if (chpid == 0) {
        printf("Factorial from child process: %lld\n", factorial(n));
    } else {
        printf("Fibonacci from parent process: %lld\n", fibonacci(n));
    }

    return 0;
}
