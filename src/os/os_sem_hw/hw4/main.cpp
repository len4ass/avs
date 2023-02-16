#include <iostream>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

const int buf_size = 1024;

char *read_bytes(char *file_name, int *size) {
    int file_descriptor;
    char *buffer = (char*)malloc(buf_size);

    if ((file_descriptor = open(file_name, O_RDONLY)) < 0) {
        puts("Can't open file for reading\n");
        return nullptr;
    }

    ssize_t read_bytes;
    char *result = (char*)malloc(buf_size * 2);
    int result_size = buf_size * 2;
    int ptr = 0;
    while (true) {
        read_bytes = read(file_descriptor, buffer, buf_size);
        if (read_bytes == -1) {
            free(result);
            free(buffer);
            close(file_descriptor);
            return nullptr;
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
        puts("Couldn't close file");
    }

    result[ptr] = '\0';
    (*size) = ptr;
    free(buffer);
    return result;
}

void write_file(char *file_name, char *buf, int len) {
    int file_descriptor;
    if ((file_descriptor = open(file_name, O_WRONLY | O_CREAT, 0666)) < 0) {
        puts("Can't open file for writing");
        return;
    }

    ssize_t size = write(file_descriptor, buf, len);
    if (size != len) {
        puts("Can't write all string");
        return;
    }

    if (close(file_descriptor) < 0) {
        puts("Can't close file");
    }
}

int main(int argc, char **argv) {
    if (argc != 3) {
	puts("Wrong argument count");
        return 1;
    }

    int sz;
    char* bytes = read_bytes(argv[1], &sz);
    if (bytes == nullptr) {
	printf("Couldn't read bytes from file %s\n", argv[1]);
        return 0;
    }

    write_file(argv[2], bytes, sz);
    free(bytes);
    return 0;
}
