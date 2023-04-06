#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <semaphore.h>
#include <string.h>
#include "encoding_helper.c"
#include "io.c"

#define SHM_KEY 5678
#define SEM_KEY 1234

union semun {
    int              val;    /* Value for SETVAL */
    struct semid_ds *buf;    /* Buffer for IPC_STAT, IPC_SET */
    unsigned short  *array;  /* Array for GETALL, SETALL */
    struct seminfo  *__buf;  /* Buffer for IPC_INFO (Linux-specific) */
};

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Некорретный формат запуска! \nИспользуйте следующий формат: ./%s proc_count\n", argv[0]);
        return 0;
    }

    // Обрабатываем количество процессов и считываем закодированное сообщение из input.txt
    int proc_count = atoi(argv[1]);
    if (proc_count < 1 || proc_count > 32) {
        perror("invalid proc_count");
        return 1;
    }

    int size;
    int *encoded_array = read_text("input.txt", &size);
    if (encoded_array == NULL) {
        perror("encoded_array");
        return 1;
    }

    // Структура для работы с семафорами
    union semun arg;

    key_t sem_key, shm_key = ftok(".", SEM_KEY);

    // Получаем ключ для семафора
    if ((sem_key = ftok(".", SEM_KEY) == -1)) {
        perror("ftok");
        return 1;
    }

    // Получаем ключ для разделяемой памяти
    if ((shm_key = ftok(".", SHM_KEY)) == -1) {
        perror("ftok");
        return 1;
    }

    // Получаем id семафора в разделяемое памяти
    int shared_sem = semget(sem_key, 1, IPC_CREAT | 0666);
    if (shared_sem == -1) {
        perror("semget");
        return 1;
    }

    // Устанавливаем начальное значение семафора
    arg.val = 1;
    if (semctl(shared_sem, 0, SETVAL, arg) == -1) {
        perror("semctl");
        return 1;
    }

    // Получаем id разделяемой памяти
    int shmid = shmget(shm_key, size + 1, IPC_CREAT | 0666);
    if (shmid == -1) {
        perror("shmget");
        exit(1);
    }

    // Присоединяем разделяемую память к процессу
    char *decoded_arr = shmat(shmid, NULL, 0);
    if (decoded_arr == (char*)-1) {
        perror("shmat");
        exit(1);
    }

    // Декодирование массива кусками
    int text_fragment_size = size / proc_count;
    for (int i = 0; i < proc_count; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            perror("fork");
            return 1;
        } else if (pid == 0) {
            // Дочерний процесс

            // Указываем кусок массива, который необходимо обработать текущему дочернему процессу
            int start = i * text_fragment_size;
            int end = start + text_fragment_size;
            if (i == proc_count - 1) {
                end += size % proc_count;
            }

            for (int j = start; j < end; ++j) {
                // Захватываем семафор
                struct sembuf sb;
                sb.sem_num = 0;
                sb.sem_op = -1;
                sb.sem_flg = 0;
                if (semop(shared_sem, &sb, 1) == -1) {
                    perror("semop");
                    return 1;
                }

                // Декодируем число в букву алфавита и записываем в разделяемую память
                decoded_arr[j] = decrypt_char(encoded_array[j]);
                printf("Декодирование в процессе %d: '%d' -> '%c'\n", i, encoded_array[j], decoded_arr[j]);

                // Отпускаем семафор
                sb.sem_op = 1;
                if (semop(shared_sem, &sb, 1) == -1) {
                    perror("semop");
                    return 1;
                }
            }

            // Выходим из дочернего процесса
            return 0;
        }
    }

    // Ждем, пока дочерние процессы завершат работу
    for (int i = 0; i < proc_count; i++) {
        wait(NULL);
    }

    decoded_arr[size] = '\0';
    puts("Результат декодирования записан в output.txt");
    write_text("output.txt", decoded_arr);

    // Отсоединяемся от сегмента разделяемой памяти
    if (shmdt(decoded_arr) == -1) {
        perror("shmdt");
        return 1;
    }

    // Удаляем сегмент разделяемой памяти
    if (shmctl(shmid, IPC_RMID, NULL) == -1) {
        perror("shmctl");
        return 1;
    }

    // Удаляем семафор
    if (semctl(shared_sem, 0, IPC_RMID, arg) == -1) {
        perror("semctl");
        return 1;
    }

    return 0;
}
