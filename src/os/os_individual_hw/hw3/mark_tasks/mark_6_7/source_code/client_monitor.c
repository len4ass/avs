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
    char *msg = malloc(sizeof(char) * 16384);

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

    // Принимаем все сообщения с сервера (синхронно)
    while (1) {
        int bytes_received = recv(client_socket, msg, sizeof(char) * 16384, 0);
        if (bytes_received < 0) {
            perror("recv");
            exit(EXIT_FAILURE);
        }

        if (strcmp("/quit", msg) == 0) {
            printf("Received server finalization signal\n");
            break;
        }

        puts(msg);
    }

    memset(msg, 0, sizeof(char) * 16384);
    int bytes_received = recv(client_socket, msg, sizeof(char) * 16384, 0);
    if (bytes_received < 0) {
        perror("recv");
        exit(EXIT_FAILURE);
    }

    printf("Decoding result: %s\n", msg);

    // Высвобождаем память
    free(msg);
    close(client_socket);
    printf("Client monitor closed\n");
    return 0;
}
