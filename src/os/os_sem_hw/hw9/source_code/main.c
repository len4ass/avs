#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <semaphore.h>

#define PIPE_READ_END 0
#define PIPE_WRITE_END 1

int main() {
    int fd[2];
    pid_t pid;
    sem_t *sem;

    if (pipe(fd) == -1) {
        perror("pipe");
        exit(EXIT_FAILURE);
    }

    if (fcntl(fd[0], F_SETFL, O_NONBLOCK) < 0) {
        perror("fnctl");
        exit(EXIT_FAILURE);
    }

    if (fcntl(fd[1], F_SETFL, O_NONBLOCK) < 0) {
        perror("fnctl");
        exit(EXIT_FAILURE);
    }

    if ((sem = sem_open("/smphr", O_CREAT, 0644, 0)) == SEM_FAILED) {
        perror("sem_open");
        exit(EXIT_FAILURE);
    }

    pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    } else if (pid == 0) { // дочерний процесс
        int i = 100;
        int msg = i;

        for (i = 100; i <= 110; i++) {
            sem_wait(sem);
            read(fd[PIPE_READ_END], &msg, sizeof(msg));
            printf("[%d] Child process read: %d\n", i - 100, msg);

            msg = i;
            write(fd[PIPE_WRITE_END], &msg, sizeof(msg));
            printf("[%d] Child process sent: %d\n", i - 100, msg);
            sem_post(sem);
            sleep(1);
        }

        close(fd[PIPE_WRITE_END]);
        close(fd[PIPE_WRITE_END]);
        sem_close(sem);
        exit(EXIT_SUCCESS);
    } else {
        int i = 1;
        int msg = i;

        for (i = 1; i <= 10; i++) {
            sem_wait(sem);
            read(fd[PIPE_READ_END], &msg, sizeof(msg));
            printf("[%d] Parent process read: %d\n", i, msg);

            msg = i;
            write(fd[PIPE_WRITE_END], &msg, sizeof(msg));
            printf("[%d] Parent process sent: %d\n", i, msg);
            sem_post(sem);
            sleep(1);
        }

        close(fd[PIPE_READ_END]);
        close(fd[PIPE_WRITE_END]);
        sem_close(sem);
        exit(EXIT_SUCCESS);
    }

    sem_close(sem);
    sem_unlink("/smphr");
    return 0;
}
