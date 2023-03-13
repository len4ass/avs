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
    int shmid;             // дескриптор объекта памяти
    message_t *msg_p;      // адрес сообщения в разделяемой памяти

    if ((shmid = shm_open(shar_object, O_CREAT|O_RDWR, 0666)) == -1) {
        perror("shm_open");
        sys_err("server: object is already open");
    } else {
        printf("Object is open: name = %s, id = 0x%x\n", shar_object, shmid);
    }

    // Задание размера объекта памяти
    if (ftruncate(shmid, sizeof(message_t)) == -1) {
        perror("ftruncate");
        sys_err ("server: memory sizing error");
        return 1;
    } else {
        printf("Memory size set and = %lu\n", sizeof (message_t));
    }

    // Получить доступ к памяти
    msg_p = mmap(0, sizeof(message_t), PROT_WRITE | PROT_READ, MAP_SHARED, shmid, 0);
    if (msg_p == (message_t*) - 1) {
    }

    msg_p->type = MSG_TYPE_EMPTY;
    while (1) {
        if (msg_p->type != MSG_TYPE_EMPTY) {
            if (msg_p->type == MSG_TYPE_ARRAY) {
                printf("Array: ");
                for (int i = 0; i < MAX_SIZE; ++i) {
                    printf("%d ", msg_p->arr[i]);
                }
                printf("\n");
            } else if (msg_p->type == MSG_TYPE_FINISH) {
                break;
            }

            msg_p->type = MSG_TYPE_EMPTY; // сообщение обработано
        }
    }

    // Удаление разделяемой памяти
    if (shm_unlink(shar_object) == -1) {
        perror("shm_unlink");
        sys_err("server: error getting pointer to shared memory");
    }

    return 0;
}

