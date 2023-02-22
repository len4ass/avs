#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

const int buf_size = 5000;

char *read_bytes(const char *name, int *size) {
    int file_descriptor;
    char *buffer = (char*)malloc(buf_size);

    if ((file_descriptor = open(name, O_RDONLY)) < 0) {
        puts("Can't open for reading");
        return NULL;
    }

    ssize_t read_bytes;
    char *result = (char*)malloc(buf_size * 2);
    int result_size = buf_size * 2;
    int ptr = 0;
    while (1) {
        read_bytes = read(file_descriptor, buffer, buf_size);
        if (read_bytes == -1) {
            free(result);
            free(buffer);
            close(file_descriptor);
            return NULL;
        }

        if (ptr < result_size) {
            memcpy(result + ptr, buffer, read_bytes);
            ptr += read_bytes;
        } else {
            char *new_buffer = (char*)malloc(result_size * 2);
            memcpy(new_buffer, result, result_size);
            free(result);
            result = new_buffer;
            ptr = result_size;
            memcpy(result + ptr, buffer, read_bytes);
            result_size *= 2;
            ptr += read_bytes;
        }

        if (read_bytes != buf_size) {
            break;
        }
    }

    if (close(file_descriptor) < 0) {
        puts("Couldn't close");
    }

    result[ptr] = '\0';
    (*size) = ptr;
    free(buffer);
    return result;
}

void write_bytes(const char *name, const char *buf, int size) {
    int file_descriptor;
    if ((file_descriptor = open(name, O_WRONLY)) < 0) {
        puts("Can't open for writing");
        return;
    }

    ssize_t write_size = write(file_descriptor, buf, size);
    if (write_size != size) {
        puts("Can't write all string");
        return;
    }

    if (close(file_descriptor) < 0) {
        puts("Can't close");
    }
}

void write_bytes_create(const char *name, const char *buf, int size) {
    int file_descriptor;
    if ((file_descriptor = open(name, O_WRONLY | O_CREAT, 0666)) < 0) {
        puts("Can't open for writing");
        return;
    }

    ssize_t write_size = write(file_descriptor, buf, size);
    if (write_size != size) {
        puts("Can't write all string");
        return;
    }

    if (close(file_descriptor) < 0) {
        puts("Can't close");
    }
}

void create_pipe(const char *pipe_name) {
    (void) umask(0);
    mknod(pipe_name, S_IFIFO | 0666, 0);
}