#include <stdio.h>
#include "pipe_helper.c"
#include "is_palindrome.c"

void run(const char *input, const char *output) {
    int *pipe_to_second = create_pipe();
    int *pipe_to_third = create_pipe();

    pid_t chpid = fork();
    if (chpid < 0) {
        puts("Failed to fork main process");
        return;
    }

    if (chpid > 0) {
        int size;
        char *str = read_bytes(input, &size);
        if (str == NULL) {
            return;
        }

        if (close(pipe_to_second[0]) < 0) {
            puts("First process: can't close reading side of pipe");
            return;
        }

        ssize_t written_size = write(pipe_to_second[1], str, size);
        if (size != written_size){
            puts("First process: can't write all string to pipe");
            return;
        }

        if (close(pipe_to_second[1]) < 0) {
            puts("First process: can't close writing side of pipe");
            return;
        }

        free(str);
    } else {
        pid_t chpid_second = fork();
        if (chpid_second < 0) {
            puts("Failed to fork second process");
            return;
        }

        if (chpid_second > 0) {
            if (close(pipe_to_second[1]) < 0) {
                puts("Second process: can't close writing side of pipe");
                return;
            }

            int size;
            char *str = read_bytes_fd(pipe_to_second[0], &size);
            if (str == NULL) {
                return;
            }

            char *result = is_palindrome(str, size);
            if (close(pipe_to_third[0]) < 0) {
                puts("Second process: can't close reading side of pipe");
                return;
            }

            ssize_t written_size = write(pipe_to_third[1], result, 1);
            if (written_size != 1) {
                puts("Second process: can't write all string to pipe");
                return;
            }

            if (close(pipe_to_third[1]) < 0) {
                puts("Second process: can't close writing side of pipe");
            }

            free(str);
        } else {
            if (close(pipe_to_third[1]) < 0) {
                puts("Third process: can't close writing side of pipe");
                return;
            }

            int size;
            char *str = read_bytes_fd(pipe_to_third[0], &size);
            if (str == NULL) {
                return;
            }

            if (close(pipe_to_third[0]) < 0) {
                puts("Third process: can't close reading side of pipe");
                return;
            }

            write_bytes_create(output, str, size);
            free(str);
        }
    }


    free(pipe_to_second);
    free(pipe_to_third);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        puts("Invalid console argument count!");
        return 0;
    }

    run(argv[1], argv[2]);
    return 0;
}
