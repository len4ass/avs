.intel_syntax noprefix
.section .rodata
output_message:
    .string "Maximum factorial argument: %llu \n"

.text
    .globl  main
    .type   main, @function
main:
    push rbp                                    # Пролог
    mov rbp, rsp                                                             

    # Подготовка цикла
    mov rax, 1                                  # Подготавливаем rax для подсчета факториала
    mov rcx, 1                                  # Ставим счетчик цикла в rcx
    loop_start:
        imul rcx                                # Производим беззнаковое умножение rax = rax * rcx
        jo loop_end                             # Если произошло переполнение, то выходим
        
        inc rcx                                 # Увеличиваем счетчик цикла
        jmp loop_start                          # Прыгаем на метку loop_start, чтобы продолжить цикл
    loop_end:
    
    lea rdi, output_message[rip]                # Передаем указатель на форматирование вывода (первый аргумент)
    mov rsi, rcx                                # Передаем максимальное значение факториала (второй аргумент)
    call printf@plt                             # Вызываем printf

    xor eax, eax                                # Нулим rax как показатель корректного завершения программы
    leave                                       # Эпилог
    ret