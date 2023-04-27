#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include "encoding_helper.c"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <IP> <Port>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *ip = argv[1];
    int port = atoi(argv[2]);
    int client_socket;
    struct sockaddr_in server_address;

    // Создаем буферы для хранения закодированной части и декодированной
    char *decoded_array = malloc(sizeof(char) * 1024);
    int *encoded_part = malloc(sizeof(int) * 1024);

    // Создаем клиентский сокет
    if ((client_socket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(port);

    // Конвертируем адрес в корректный формат
    if (inet_pton(AF_INET, ip, &server_address.sin_addr) <= 0) {
        perror("inet_pton");
        exit(EXIT_FAILURE);
    }

    // Присоединяемся к серверу
    if (connect(client_socket, (struct sockaddr *) &server_address, sizeof(server_address)) < 0) {
        perror("connect");
        exit(EXIT_FAILURE);
    }

    // Получаем закодированный массив
    int bytes_received = recv(client_socket, encoded_part, sizeof(int) * 1024, 0);
    if (bytes_received < 0) {
        perror("Recv failed");
        exit(EXIT_FAILURE);
    }

    printf("Received encoded array from server\n");

    // Определяем размер полученного закодированного массива и декодируем его
    int size = bytes_received / sizeof(int);
    for (int i = 0; i < size; i++) {
        decoded_array[i] = decrypt_char(encoded_part[i]);
    }
    decoded_array[size] = '\0';

    printf("Decoded array: %s\n", decoded_array);
    printf("Sending response back to server\n");

    // Отправляем декодированный массив обратно на сервер
    send(client_socket, decoded_array, size, 0);

    // Высвобождаем память
    free(decoded_array);
    free(encoded_part);
    close(client_socket);
    printf("Client closed\n");
    return 0;
}
