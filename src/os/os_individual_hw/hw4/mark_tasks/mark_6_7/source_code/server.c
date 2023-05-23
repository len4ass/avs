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

typedef struct {
    int sockfd;
    struct sockaddr_in client_addr;
} ClientThreadArgs;


char *int_array_to_string(int *arr, int size) {
    char *string = malloc(sizeof(char) * 1024);

    strcpy( string, "[" );
    for (size_t i = 0; i < size - 1; i++)
    {
        sprintf(&string[strlen(string)], "%d, ", arr[i]);
    }

    sprintf(&string[strlen(string)],"%d", arr[size - 1]);
    strcat(string, "]");
    return string;
}

int main(int argc, char *argv[]) {
    if (argc != 3 && argc != 4) {
        printf("Usage: %s <Port> <Proc Count> <optional:client_monitor\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int client_monitor = argc == 4 ? 1 : 0;
    ClientThreadArgs client_monitor_address;
    int port = atoi(argv[1]);
    if (port < 1 || port > 65536) {
        printf("Proc count must be in [1, 65536] range\n");
        exit(EXIT_FAILURE);
    }

    int proc_count = atoi(argv[2]);
    if (proc_count < 0 || proc_count > 32) {
        printf("Proc count must be in [1, 32] range\n");
        exit(EXIT_FAILURE);
    }

    // Массив для декодирования
    int size;
    int *encoded_array = read_text("input.txt", &size);
    if (encoded_array == NULL) {
        perror("encoded_array");
        exit(EXIT_FAILURE);
    }

    // Создаем массивы для хранения дескрипторов соединений и адресов клиентов
    ClientThreadArgs *connections = (ClientThreadArgs*)malloc(sizeof(ClientThreadArgs) * proc_count);
    struct sockaddr_in *client_addresses = malloc(sizeof(struct sockaddr_in) * proc_count);

    int server_socket;
    struct sockaddr_in server_address;
    if ((server_socket = socket(AF_INET, SOCK_DGRAM, 0)) == 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    // Биндим сокет
    if (bind(server_socket, (struct sockaddr *)&server_address, sizeof(server_address)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }

    printf("Server started on port %d\n", port);
    printf("Waiting for %d connections to occur\n", proc_count);
    if (client_monitor == 1) {
        printf("Waiting client monitor to connect\n");
        socklen_t address_len = sizeof(client_monitor_address.client_addr);
        int buffer;
        int recv_len = recvfrom(server_socket, &buffer, sizeof(int), 0, (struct sockaddr*)&client_monitor_address.client_addr, &address_len);
        if (recv_len < 0) {
            perror("Failed to get data.");
            exit(EXIT_FAILURE);
        }

        client_monitor_address.sockfd = server_socket;
        //client_monitor = accept(server_socket, (struct sockaddr *)&client_monitor_address, &address_len);
        printf("Connected client monitor.\n");
    }

    // Ждем proc_count подключений
    for (int i = 0; i < proc_count; i++) {
        socklen_t address_len = sizeof(connections[i].client_addr);
        int buffer;
        int recv_len = recvfrom(server_socket, &buffer, sizeof(int), 0, (struct sockaddr*)&connections[i].client_addr, &address_len);
        if (recv_len < 0) {
            perror("recvfrom");
            exit(EXIT_FAILURE);
        }

        connections[i].sockfd = server_socket;
        //connections[i] = accept(server_socket, (struct sockaddr *)&(client_addresses[i]), &address_len);
        printf("Connected client %d\n", i + 1);
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

            // Указываем начало и конец массива, который отправим на декодирование клиенту с номером i
            int start = i * text_fragment_size;
            int end = start + text_fragment_size;
            if (i == proc_count - 1) {
                end += size % proc_count;
            }

            // Сделаем копию необходимого участка массива
            int *buffer = malloc(sizeof(int) * (end - start));
            int k = 0;
            for (int j = start; j < end; ++j) {
                buffer[k++] = encoded_array[j];
            }

            socklen_t address_len = sizeof(connections[i].client_addr);
            // Отправляем (end - start) * sizeof(int) байт
            int bytes_send = sendto(connections[i].sockfd, &encoded_array[start], sizeof(int) * (end - start), 0, (struct sockaddr*)&connections[i].client_addr, address_len);
            if (bytes_send < 0) {
                printf("Failed sending data to client %d\n", i + 1);
                perror("sendto");
            }

            // Дебаг сообщение для клиент монитора
            char *str = malloc(sizeof(char) * 2048);
            char *array_to_str = int_array_to_string(buffer, end - start);
            snprintf(str, sizeof(char) * 2048, "Server sent array to client %d: %s", i + 1, array_to_str);
            // Отправка сообщения клиент монитору о том, что сервер послал закодированный массив клиенту

            socklen_t client_monitor_len = sizeof(client_monitor_address.client_addr);
            sendto(client_monitor_address.sockfd, str, sizeof(char) * 2048, 0, (struct sockaddr*)&client_monitor_address.client_addr, client_monitor_len);

            // Принимаем декодированный участок end - start байт
            // Принимаем декодированный участок end - start байт
            int bytes_received = recvfrom(connections[i].sockfd, decoded_arr + start, end - start, 0, (struct sockaddr*)&connections[i].client_addr, &address_len);
            if (bytes_received < 0) {
                printf("Failed getting data back from client %d\n", i + 1);
                perror("recvfrom");
            }
            char *received_part = malloc(sizeof(char) * (end - start + 1));
            received_part[end - start] = '\0';
            memcpy(received_part, decoded_arr + start, end - start);

            // Отправка сообщения клиент монитору о том, что сервер получил от клиента декодированный массив
            snprintf(str, sizeof(char) * 2048, "Server got decoded array from client %d: %s", i + 1, received_part);
            sendto(client_monitor_address.sockfd, str, sizeof(char) * 2048, 0, (struct sockaddr*)&client_monitor_address.client_addr, client_monitor_len);

            free(str);
            free(array_to_str);
            free(received_part);
            free(buffer);
            return 0;
        }
    }

    // Ждем завершения дочерних процессов
    for (int i = 0; i < proc_count; i++) {
        wait(NULL);
    }

    socklen_t client_monitor_len = sizeof(client_monitor_address.client_addr);
    // Посылаем сигнал о завершении монитору
    char fin_msg[] = {"/quit"};
    sendto(client_monitor_address.sockfd, fin_msg, sizeof(fin_msg), 0, (struct sockaddr*)&client_monitor_address.client_addr, client_monitor_len);

    // Ставим NULL на конец строки для корректного вывода
    decoded_arr[size] = '\0';

    // Посылаем результат декодирования монитору
    sendto(client_monitor_address.sockfd, decoded_arr, size + 1, 0, (struct sockaddr*)&client_monitor_address.client_addr, client_monitor_len);

    // Записываем результат декодирования в файл
    write_text("output.txt", decoded_arr);
    printf("Decoded array has been written to output.txt\n");

    // Закрываем дескрипторы соединения с клиентами
    //for (int i = 0; i < proc_count; i++) {
    //    close(connections[i]);
    //}

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

    // Высвобождаем память
    free(encoded_array);
    free(connections);
    close(server_socket);
    printf("Server closed\n");
    return 0;
}
