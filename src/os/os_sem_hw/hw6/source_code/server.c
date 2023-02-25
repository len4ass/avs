#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define SERVER_KEY_PATHNAME "/tmp/cl_sv_com"
#define PROJECT_ID 'M'
#define QUEUE_PERMISSIONS 0660

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
    int queue_id;
    struct message message;

    if ((message_queue_key = ftok(SERVER_KEY_PATHNAME, PROJECT_ID)) < 0) {
        puts("Failed to get message queue key");
        return 1;
    }

    if ((queue_id = msgget (message_queue_key, IPC_CREAT | QUEUE_PERMISSIONS)) < 0) {
        puts("Failed setting up server queue");
        return 1;
    }

    puts("Server has started!");
    while (1) {
        if (msgrcv(queue_id, &message, sizeof(struct message_text), 0, 0) < 0) {
            puts("Failed receiving message from the client");
            return 1;
        }

        // Здесь может быть любая логика обработки сообщений от клиента, я решил просто отсылать обратно строку вида:
        // "Size of the string: %lu";
        printf("Server received a message from the client: %s\n", message.message_text.message_buffer);
        unsigned long length = strlen(message.message_text.message_buffer);
        char buf[] = "Size of the string:";
        char size[5];
        sprintf(size, " %lu", length);
        strcat(buf, size);

        unsigned long i;
        for (i = 0; i < strlen(buf); ++i) {
            message.message_text.message_buffer[i] = buf[i];
        }
        message.message_text.message_buffer[i] = '\0';

        int client_queue_id = message.message_text.queue_id;
        message.message_text.queue_id = queue_id;
        if (msgsnd(client_queue_id, &message, sizeof(struct message_text), 0) < 0) {
            puts("Failed sending message to the client");
            return 1;
        }

        printf("Server sent response to the client: %s\n", message.message_text.message_buffer);
    }
}
