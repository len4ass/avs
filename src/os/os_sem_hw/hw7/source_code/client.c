#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>

#include "message.h"

const char* shar_object = "array_shared_object";

void sys_err(char *msg) {
    puts(msg);
    exit(1);
}

int main() {
    int shmid;            // дескриптор разделяемой памяти
    message_t *msg_p;     // адрес сообщения в разделяемой памяти
    int arr[MAX_SIZE];   // текст сообщения
    char input[10];

    if ((shmid = shm_open(shar_object, O_CREAT|O_RDWR, 0666)) == -1) {
        perror("shm_open");
        sys_err("client: object is already open");
    } else {
        printf("Object is open: name = %s, id = 0x%x\n", shar_object, shmid);
    }

    // Получить доступ к разделяемой памяти
    msg_p = mmap(0, sizeof(message_t), PROT_WRITE | PROT_READ, MAP_SHARED, shmid, 0);
    if (msg_p == (message_t*) - 1) {
    }

    // Организация передачи массива
    while (1) {
        fgets(input, 10, stdin);
        int len = strlen(input);
        input[len - 1] = '\0';
        if (input[0] != 'q') {
            srand(time(NULL));
            for (int i = 0; i < MAX_SIZE; ++i) {
                arr[i] = rand();
            }
            msg_p->type = MSG_TYPE_ARRAY;
            memcpy(msg_p->arr, arr, MAX_SIZE * sizeof(int));
        } else {
            msg_p->type = MSG_TYPE_FINISH;
        }

        if (msg_p->type == MSG_TYPE_FINISH) {
          break;
        }
    }

    // Окончание цикла передачи сообщений
    // Закрыть открытый объект
    close(shmid);
    return 0;
}

