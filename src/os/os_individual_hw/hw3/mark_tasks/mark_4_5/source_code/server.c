#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "io.c"
#define SHM_NAME "/mem"

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <IP> <Port> <Proc Count>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int port = atoi(argv[2]);
    if (port < 1 || port > 65536) {
        printf("Proc count must be in [1, 65536] range\n");
        exit(EXIT_FAILURE);
    }

    int proc_count = atoi(argv[3]);
    if (proc_count < 0 || proc_count > 32) {
        printf("Proc count must be in [1, 32] range\n");
        exit(EXIT_FAILURE);
    }

    int size;
    int *encoded_array = read_text("input.txt", &size);
    if (encoded_array == NULL) {
        perror("encoded_array");
        exit(EXIT_FAILURE);
    }

    int *connections = (int*)malloc(sizeof(int) * proc_count);
    struct sockaddr_in *client_addresses = malloc(sizeof(struct sockaddr_in) * proc_count);

    int server_socket;
    struct sockaddr_in server_address;
    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *)&server_address, sizeof(server_address)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }

    if (listen(server_socket, proc_count) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    printf("Server started on port %d\n", port);
    printf("Waiting for %d connection to occur\n", proc_count);
    for (int i = 0; i < proc_count; i++) {
        socklen_t address_len = sizeof(client_addresses[i]);
        connections[i] = accept(server_socket, (struct sockaddr *)&(client_addresses[i]), &address_len);
        printf("Connected client %d: %s:%d\n", i + 1, inet_ntoa(client_addresses[i].sin_addr), ntohs(client_addresses[i].sin_port));
    }

    int text_fragment_size = size / proc_count;
    // Создаем разделяемую память для декодированного массива
    int shm_fd = shm_open(SHM_NAME, O_CREAT | O_RDWR, 0666);
    if (shm_fd == -1) {
        perror("shm_open");
        exit(EXIT_FAILURE);
    }

    // Устанавливаем размер памяти
    if (ftruncate(shm_fd, size + 1) == -1) {
        perror("ftruncate");
        exit(EXIT_FAILURE);
    }

    // Присоединяем память к процессу
    char *decoded_arr = mmap(NULL, size + 1, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (decoded_arr == MAP_FAILED) {
        perror("mmap");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < proc_count; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            perror("fork");
            return 1;
        } else if (pid == 0) {
            // Дочерний процесс

            int start = i * text_fragment_size;
            int end = start + text_fragment_size;
            if (i == proc_count - 1) {
                end += size % proc_count;
            }

            int *buffer = malloc(sizeof(int) * (end - start));
            int k = 0;
            for (int j = start; j < end; ++j) {
                buffer[k++] = encoded_array[j];
            }

            send(connections[i], buffer, sizeof(int) * (end - start), 0);
            int bytes_received = recv(connections[i], decoded_arr + start, end - start, 0);
            if (bytes_received < 0) {
                printf("Failed getting data back from client %d\n", i);
            }

            free(buffer);
            return 0;
        }
    }

    for (int i = 0; i < proc_count; i++) {
        wait(NULL);
    }

    decoded_arr[size] = '\0';
    write_text("output.txt", decoded_arr);
    printf("Decoded array has been written to output.txt\n");

    for (int i = 0; i < proc_count; i++) {
        close(connections[i]);
    }

    // Удаляем память выделенную под декодированную строку
    if (munmap(decoded_arr, size) == -1) {
        perror("munmap");
        return 1;
    }

    // Закрываем поток к разделяемой памяти
    if (close(shm_fd) == -1) {
        perror("close");
        return 1;
    }

    // Удаляем разделяемую память
    if (shm_unlink(SHM_NAME) == -1) {
        perror("shm_unlink");
        return 1;
    }

    free(encoded_array);
    free(connections);
    close(server_socket);
    printf("Server closed\n");
    return 0;
}
