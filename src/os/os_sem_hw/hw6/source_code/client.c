#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define SERVER_KEY_PATHNAME "/tmp/cl_sv_com"
#define PROJECT_ID 'M'

struct message_text {
    int queue_id;
    char message_buffer[200];
};

struct message {
    long message_type;
    struct message_text message_text;
};

int main() {
    key_t message_queue_key;
    int server_queue_id;
    int client_queue_id;
    struct message client_message, server_message;

    if ((client_queue_id = msgget(IPC_PRIVATE, 0660)) < 0) {
        puts("Failed setting up client queue");
        return 1;
    }

    if ((message_queue_key = ftok(SERVER_KEY_PATHNAME, PROJECT_ID)) < 0) {
        puts("Failed to get server queue key");
        return 1;
    }

    if ((server_queue_id = msgget(message_queue_key, 0)) < 0) {
        puts("Failed getting server queue id");
        return 1;
    }

    client_message.message_type = 1;
    client_message.message_text.queue_id = client_queue_id;
    printf("Please type a message: ");

    while (fgets(client_message.message_text.message_buffer, 198, stdin)) {
        unsigned long length = strlen(client_message.message_text.message_buffer);
        if (client_message.message_text.message_buffer[length - 1] == '\n') {
            client_message.message_text.message_buffer[length - 1] = '\0';
        }

        if (strcmp("q", client_message.message_text.message_buffer) == 0) {
            puts("Client decided to exit");
            break;
        }

        if (msgsnd(server_queue_id, &client_message, sizeof(struct message_text), 0) < 0) {
            puts("Failed sending message to the server");
            return 1;
        }

        if (msgrcv(client_queue_id, &server_message, sizeof(struct message_text), 0, 0) < 0) {
            puts("Failed getting message from the server");
            return 1;
        }

        printf("Received message from the server: %s\n\n", server_message.message_text.message_buffer);
        printf("Please type a message: ");
    }

    if (msgctl(client_queue_id, IPC_RMID, NULL) < 0) {
        puts("Failed destroying message queue on client side");
        return 1;
    }

    puts("Finalizing client side");
    return 0;
}

