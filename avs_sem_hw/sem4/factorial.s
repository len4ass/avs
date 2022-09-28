.intel_syntax noprefix
.section .rodata
input_message:
    .string "Enter number for factorial: "

output_message:
    .string "Result: %lu \n"

format_input_uint64:
    .string "%lu"

.section .data
factorial_arg:
    .quad   0

factorial:
    .quad  1

.text
    .globl  main
    .type   main, @function
main:
    push    rbp                             # Пушим указатель стэка
    mov     rbp, rsp                        # Делаем копию

    # Подсказка для ввода factorial_arg
    lea     rdi, input_message[rip]         # Передаем указатель на сообщение для вывода (первый аргумент printf)
    mov     eax, 0                          # Чистим регистр перед вызовом (ну мало ли заходим обработать результат вызова)
    call    printf@PLT                      # Вызываем printf

    # Ввод factorial_arg
    lea     rdi, format_input_uint64[rip]   # Передаем указатель на форматирование ввода (первый аргумент)
    lea     rsi, factorial_arg[rip]         # Передаем указатель для записи числа с консоли (второй аргумент)
    mov     eax, 0                          # Чистим регистр перед вызовом
    call    scanf@plt                       # Вызываем scanf

    # Подготовка цикла
    mov rax, factorial[rip]                 # Делаем копию факториала в регистр rax (mul как и все вызовы возвращают результат в ax)
    mov rbx, factorial_arg[rip]             # Делаем копию числа, для которого считаем факториал в rbx
    mov rcx, 1                              # Ставим счетчик цикла в rcx
loop_start:
    cmp rcx, rbx                            # Сравниваем счетчик цикла и то число, для которого считаем факториал
    ja loop_end                             # Если текущий счетчик цикла строго больше числа, для которого считаем факториал,
                                            # то выходим из цикла прыжком на метку loop_end
    mul rcx                                 # Производим беззнаковое умножение rax = rax * rcx
    inc rcx                                 # Увеличиваем счетчик цикла
    jmp loop_start                          # Прыгаем на метку loop_start, чтобы продолжить цикл
loop_end:
    mov factorial[rip], rax                 # Делаем копию результата факториала (перемещаем обратно в нашу изначальную переменную в секции data)
    mov rax, 0                              # Чистим регистр rax как показатель того, что мы закончили подсчет факториала

    lea rdi, output_message[rip]            # Передаем указатель на форматирование вывода (первый аргумент)
    mov rsi, factorial[rip]                 # Делаем копию результата факториала (второй аргумент)
    mov eax, 0                              # Чистим регистр перед вызовом
    call printf@plt                         # Вызываем printf

    mov	eax, 0                              # Очистка регистра eax перед окончанием работы программы
    pop	rbp                                 # Восстанавливаем указатель стэка
    ret

