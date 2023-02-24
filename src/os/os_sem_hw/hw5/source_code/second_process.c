#include <stdio.h>
#include "pipe_helper.c"

void run(const char *first_fifo, const char *second_fifo) {
    int fd;
    if ((fd = open(first_fifo, O_RDONLY)) < 0) {
        puts("Second process: can't open for reading");
        return;
    }

    int size;
    char *str = read_bytes_fd(fd, &size);
    if (str == NULL) {
        return;
    }

    if (close(fd) < 0) {
        puts("Second process: can't close after reading");
        return;
    }

    printf("Second process got message: %s", str);
    free(str);

    char first_proc[] = "Hello from second process\n";
    size = strlen(first_proc);
    if ((fd = open(second_fifo, O_WRONLY)) < 0) {
        puts("Second process: can't open for writing");
        return;
    }

    ssize_t written_size = write(fd, first_proc, size);
    if (written_size != size) {
        puts("Second process: can't write all string");
        return;
    }

    if (close(fd) < 0) {
        puts("Second process: can't close for writing");
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

