#include <mpi.h>
#include <cstdio>
#include <thread>
#include <chrono>

const int len = 50;

int main(int argc, char** argv) {
    int i, rank, size;
    char buffer[len];

    MPI_Status status;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != 3) {
        printf("Process %d, Incorrect processes number = %d. Only three processes are possible!\n", rank, size);
        MPI_Finalize();
        return 0;
    }

    sprintf_s(buffer, "Hello from %d", rank); // формирование сообщения
    auto t1 = MPI_Wtime();  // фиксация времени «начала посылки», 
    // локально для каждого процесса
    if (rank == 0) {
        MPI_Send(buffer, len, MPI_CHAR, 1, 0, MPI_COMM_WORLD); // (1)
    }
    else if (rank == 1) {
        MPI_Send(buffer, len, MPI_CHAR, 2, 1, MPI_COMM_WORLD); // (2)        
    }
    else if (rank == 2) {
        MPI_Send(buffer, len, MPI_CHAR, 0, 2, MPI_COMM_WORLD); // (2)        
    }

    printf("Process %d. Message: \"%s\" have sent\n", rank, buffer);

    if (rank == 0) {
        MPI_Recv(buffer, len, MPI_CHAR, 2, 2, MPI_COMM_WORLD, &status); // (2)        
    }
    else if (rank == 1) {
        MPI_Recv(buffer, len, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status); // (2)        
    } 
    else if (rank == 2) {
        MPI_Recv(buffer, len, MPI_CHAR, 1, 1, MPI_COMM_WORLD, &status); // (2)        
    }

    auto t2 = MPI_Wtime(); // фиксация времени «окончания приема», 
    // локально для каждого процесса
    printf("Process %d ---> Buffer = %s\n", rank, buffer);   // вывод сообщения
    printf("From process %d. Time = %le\n", rank, (t2 - t1)); // вывод времени, 
    // затраченного на обмен данным процессором
    MPI_Finalize();
    return 0;
}
