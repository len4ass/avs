#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <string.h>
#include "encoding_helper.c"
#include "io.c"

#define SEM_NAME "/sem"
#define SHM_NAME "/mem"

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

    // Создаем семафор
    sem_t *sem = sem_open(SEM_NAME, O_CREAT, 0666, 1);
    if (sem == SEM_FAILED) {
        perror("sem_open");
        return 1;
    }

    // Создаем разделяемую память для декодированного массива
    int shm_fd = shm_open(SHM_NAME, O_CREAT | O_RDWR, 0666);
    if (shm_fd == -1) {
        perror("shm_open");
        return 1;
    }

    // Устанавливаем размер памяти
    if (ftruncate(shm_fd, size + 1) == -1) {
        perror("ftruncate");
        return 1;
    }

    // Присоединяем память к процессу
    char *decoded_arr = mmap(NULL, size + 1, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
    if (decoded_arr == MAP_FAILED) {
        perror("mmap");
        return 1;
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
                // Блокируем семафор
                sem_wait(sem);
                // Декодируем число в букву алфавита и записываем в разделяемую память
                decoded_arr[j] = decrypt_char(encoded_array[j]);
                printf("Декодирование в процессе %d: '%d' -> '%c'\n", i, encoded_array[j], decoded_arr[j]);

                // Отпускаем семафор
                sem_post(sem);
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

    // Закрываем семафор
    if (sem_close(sem) == -1) {
        perror("sem_close");
        return 1;
    }

    // Удаляем семафор
    if (sem_unlink(SEM_NAME) == -1) {
        perror("sem_unlink");
        return 1;
    }

    return 0;
}
