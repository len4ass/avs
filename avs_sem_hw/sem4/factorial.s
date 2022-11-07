.intel_syntax noprefix
.section .rodata
input_message:
    .string "Enter number for factorial: "

format_output_uint64:
    .string "Result: %llu \n"

format_input_uint64:
    .string "%llu"

.text
    .globl  main
    .type   main, @function
main:
    push rbp                                    # Пролог
    mov rbp, rsp                                             
    sub rsp, 16

    # Подсказка для ввода factorial_arg
    lea rdi, input_message[rip]                 # Передаем указатель на сообщение для вывода (первый аргумент printf)
    call printf@PLT                             # Вызываем printf

    # Ввод числа, для которого считаем факториал
    lea rdi, format_input_uint64[rip]           # Передаем указатель на форматирование ввода (первый аргумент)
    lea rsi, qword ptr[rbp - 16]                # Передаем указатель для записи числа с консоли (второй аргумент)
    call scanf@plt                              # Вызываем scanf

    # Подготовка цикла
    mov rax, 1                                  # Подготавливаем rax для подсчета факториала 
    mov rcx, 1                                  # Ставим счетчик цикла в rcx
    loop_start:
        cmp rcx, qword ptr[rbp - 16]                            # Сравниваем счетчик цикла и то число, для которого считаем факториал
        ja loop_end                             # Если текущий счетчик цикла строго больше числа, для которого считаем факториал,
                                                # то выходим из цикла прыжком на метку loop_end
        imul rcx                                 # Производим беззнаковое умножение rax = rax * rcx
        inc rcx                                 # Увеличиваем счетчик цикла
        jmp loop_start                          # Прыгаем на метку loop_start, чтобы продолжить цикл
    loop_end:
    lea rdi, format_output_uint64[rip]          # Передаем указатель на форматирование вывода (первый аргумент)
    mov rsi, rax                                # Передаем факториал (второй аргумент)
    call printf@plt                             # Вызываем printf

    xor eax, eax                                # Нулим rax как показатель корректного завершения программы
    leave                                       # Эпилог
    ret