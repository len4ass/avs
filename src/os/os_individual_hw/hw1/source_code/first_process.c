#include <stdio.h>
#include "pipe_helper.c"

void run(const char *input, const char *output) {
    int size;
    char *str = read_bytes(input, &size);
    if (str == NULL) {
        return;
    }

    create_pipe("pass_string.fifo");
    write_bytes("pass_string.fifo", str, size);
    int result_size;
    char *result = read_bytes("pass_result.fifo", &result_size);
    if (result == NULL) {
        return;
    }

    write_bytes_create(output, result, result_size);
    free(str);
    free(result);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        puts("Invalid console argument count!");
        return 0;
    }

    run(argv[1], argv[2]);
    return 0;
}
