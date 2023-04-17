#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT 5555

int main(int argc, char *argv[]) {
    int server_socket, conn1, conn2;
    struct sockaddr_in server_address, client_address1, client_address2;
    char buffer[1024] = {0};

    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(PORT);

    if (bind(server_socket, (struct sockaddr *)&server_address, sizeof(server_address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_socket, 2) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    printf("Server started on port %d\n", PORT);

    socklen_t address_len1 = sizeof(client_address1);
    conn1 = accept(server_socket, (struct sockaddr *)&client_address1, &address_len1);
    printf("Connected client 1: %s:%d\n", inet_ntoa(client_address1.sin_addr), ntohs(client_address1.sin_port));

    socklen_t address_len2 = sizeof(client_address2);
    conn2 = accept(server_socket, (struct sockaddr *)&client_address2, &address_len2);
    printf("Connected client 2: %s:%d\n", inet_ntoa(client_address2.sin_addr), ntohs(client_address2.sin_port));

    while (1) {
        int bytes_received = recv(conn1, buffer, sizeof(buffer), 0);
        if (bytes_received < 0) {
            perror("Recv failed");
            exit(EXIT_FAILURE);
        }
        buffer[bytes_received] = '\0';
        send(conn2, buffer, strlen(buffer), 0);

        if (strcmp(buffer, "The End\n") == 0) {
            break;
        }
    }

    close(conn1);
    close(conn2);
    close(server_socket);
    printf("Server closed\n");

    return 0;
}
