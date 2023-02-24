#include <stdio.h>
#include "pipe_helper.c"

void run(const char *first_fifo, const char *second_fifo) {
    create_fifo(first_fifo);
    create_fifo(second_fifo);

    char first_proc[] = "Hello from first process\n";
    int size = strlen(first_proc);

    int fd;
    if ((fd = open(first_fifo, O_WRONLY)) < 0) {
        puts("First process: can't open for writing");
        return;
    }

    ssize_t written_size = write(fd, first_proc, size);
    if (size != written_size) {
        puts("First process: can't write all string");
        return;
    }

    if (close(fd) < 0) {
        puts("First process: can't close after writing");
        return;
    }

    if ((fd = open(second_fifo, O_RDONLY)) < 0) {
        puts("First process: can't open for reading");
        return;
    }

    char *str = read_bytes_fd(fd, &size);
    if (str == NULL) {
        return;
    }

    printf("First process got message: %s", str);
    if (close(fd) < 0) {
        puts("First process: can't close after reading");
        return;
    }

    free(str);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        puts("Invalid console argument count!");
        return 0;
    }

    run(argv[1], argv[2]);
    return 0;
}
