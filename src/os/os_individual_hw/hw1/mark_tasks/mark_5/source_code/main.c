#include <stdio.h>
#include "pipe_helper.c"
#include "is_palindrome.c"

void run(const char *input, const char *output) {
    create_fifo("to_second.fifo");
    create_fifo("to_third.fifo");

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

        int fd;
        if ((fd = open("to_second.fifo", O_WRONLY)) < 0) {
            puts("First process: can't open to_second.fifo for writing");
            return;
        }

        ssize_t written_size = write(fd, str, size);
        if (size != written_size){
            puts("First process: can't write all string to fifo");
            return;
        }

        if (close(fd) < 0) {
            puts("First process: can't close to_second.fifo after writing");
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
            int fd;
            if ((fd = open("to_second.fifo", O_RDONLY)) < 0) {
                puts("Second process: can't open to_second.fifo for reading");
                return;
            }

            int size;
            char *str = read_bytes_fd(fd, &size);
            if (str == NULL) {
                return;
            }

            if (close(fd) < 0) {
                puts("Second process: can't close to_second.fifo after reading");
                return;
            }

            char *result = is_palindrome(str, size);
            if ((fd = open("to_third.fifo", O_WRONLY)) < 0) {
                puts("Second process: can't open to_third.fifo for writing");
                return;
            }

            ssize_t written_size = write(fd, result, 1);
            if (written_size != 1) {
                puts("Second process: can't write all string to fifo");
                return;
            }

            if (close(fd) < 0) {
                puts("Second process: can't close to_third.fifo for writing");
            }

            free(str);
        } else {
            int fd;
            if ((fd = open("to_third.fifo", O_RDONLY)) < 0) {
                puts("Third process: can't open to_third.fifo for reading");
                return;
            }

            int size;
            char *str = read_bytes_fd(fd, &size);
            if (str == NULL) {
                return;
            }

            if (close(fd) < 0) {
                puts("Third process: can't close to_third.fifo after reading");
                return;
            }

            write_bytes_create(output, str, size);
            free(str);
        }
    }
}

int main(int argc, char **argv) {
    if (argc != 3) {
        puts("Invalid console argument count!");
        return 0;
    }

    run(argv[1], argv[2]);
    return 0;
}
