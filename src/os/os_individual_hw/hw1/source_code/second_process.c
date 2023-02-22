#include <stdio.h>
#include "pipe_helper.c"

char* is_palindrome(const char *string, int size) {
    int left = 0;
    int right = size - 1;

    while (right - left > 0) {
        if (string[left++] != string[right--]) {
            return "0";
        }
    }

    return "1";
}

void run() {
    int size;
    char *str = read_bytes("pass_string.fifo", &size);
    if (str == NULL) {
        return;
    }

    char *result = is_palindrome(str, size);
    create_pipe("pass_result.fifo");
    write_bytes("pass_result.fifo", result, 1);
    free(str);
}

int main() {
    run();
    return 0;
}
