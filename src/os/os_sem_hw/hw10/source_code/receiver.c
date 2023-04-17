#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

#define BIT_COUNT 32

volatile pid_t transmitter_pid;
volatile sig_atomic_t received_bits[BIT_COUNT]; // биты, принятые от передатчика
volatile sig_atomic_t current_bit = 0; // текущий ожидаемый бит

void handler(int sig) {
    if (sig == SIGUSR1) {
        received_bits[current_bit] = 0;
        printf("Received bit %d\n", received_bits[current_bit]);
        current_bit++;
        kill(transmitter_pid, SIGUSR1); // отправка подтверждения
    } else if (sig == SIGUSR2) {
        received_bits[current_bit] = 1;
        printf("Received bit %d\n", received_bits[current_bit]);
        current_bit++;
        kill(transmitter_pid, SIGUSR1); // отправка подтверждения
    } else if (sig == SIGINT) {
        // принята последняя порция данных, можно завершаться
        int num = 0;
        for (int i = 0; i < BIT_COUNT; i++) {
            if (received_bits[i] == 1) {
                num |= (1 << i);
            }
        }
        printf("Received integer: %d\n", num);
        exit(0);
    }
}

int main() {
    // получаем свой PID
    int receiver_pid = getpid();
    printf("Receiver PID: %d\n", receiver_pid);

    // запрашиваем PID передатчика
    printf("Enter transmitter PID: ");
    scanf("%d", &transmitter_pid);

    printf("Got transmitter PID: %d\n", transmitter_pid);

    signal(SIGUSR1, handler);
    signal(SIGUSR2, handler);
    signal(SIGINT, handler);

    while (1) {
        if (current_bit != 32) {
            continue;
        }

        break;
    }
}
