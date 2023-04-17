#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

#define BIT_COUNT 32

volatile sig_atomic_t ack = 0; // флаг подтверждения от приемника

void handler(int sig) {
    if (sig == SIGUSR1) {
        ack = 1;
    }
}

int main() {
    int receiver_pid;
    int num;

    signal(SIGUSR1, handler);

    // получаем свой PID
    int transmitter_pid = getpid();
    printf("Transmitter PID: %d\n", transmitter_pid);

    // запрашиваем PID приемника
    printf("Enter receiver PID: ");
    scanf("%d", &receiver_pid);

    // запрашиваем целое число для передачи
    printf("Enter integer: ");
    scanf("%d", &num);

    // побитовая передача числа
    for (int i = 0; i < BIT_COUNT; i++) {
        int bit = (num >> i) & 1;

        // отправка бита приемнику
        ack = 0;
        if (bit == 0) {
            kill(receiver_pid, SIGUSR1);
        } else {
            kill(receiver_pid, SIGUSR2);
        }

        // ожидание подтверждения
        while (ack == 0) {
        }
    }

    // отправка сигнала о завершении передачи
    kill(receiver_pid, SIGINT);

    return 0;
}
