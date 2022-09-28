.intel_syntax noprefix
.section .rodata
    msg_input_size:
        .string "Enter array size: "

    input_element:
        .string "Enter element: "

    output_array_initial:
        .string "Initial array: "

    output_array_transformed:
        .string "New array: "

    output_array_end:
        .string "\n"

    format_output_uint64:
        .string "%lu "

    format_input_uint64:
        .string "%lu"

.text
    .globl  main
    .type   main, @function
    .type   read_array, @function
    .type   print_array, @function

    read_array:
        # Сохраняем указатель стэка
        push rbp
        mov rbp, rsp

        # Выделим память под размер массива, указатель на массив, текущее значение и переменную цикла
        sub rsp, 32
        mov qword ptr[rbp - 32], rdi    # Размер массива
        mov qword ptr[rbp - 24], 0      # Текущее значение
        mov qword ptr[rbp - 16], 0      # Переменная цикла
        mov qword ptr[rbp - 8], 0       # Указатель на массив

        # Умножим размер массива на 8 и получим размер в байтах для malloc
        mov rax, qword ptr[rbp - 32]
        mov rbx, 8
        mul rbx

        # Выделяем память через malloc
        mov rdi, rax
        call malloc@plt

        # Сохраняем указатель
        mov qword ptr[rbp - 8], rax

        # Цикл для заполнения массива
        loop_read_start:
            # Сравнение переменной цикла с размером, если >= размера, то прыжок на конец
            mov rcx, qword ptr[rbp - 16]
            cmp rcx, qword ptr[rbp - 32]
            jge loop_read_end

            # Подсказка для ввода
            lea rdi, input_element[rip]
            mov eax, 0
            call printf@plt

            # Ввод элемента в переменную на стэке
            lea rdi, format_input_uint64[rip]
            lea rsi, qword ptr[rbp - 24]
            mov eax, 0
            call scanf@plt

            mov rbx, qword ptr[rbp - 24]    # Записываем считанный элемент в регистр
            mov rdx, qword ptr[rbp - 8]     # Записываем указатель на наш массив в регистр
            mov r8, qword ptr[rbp - 16]     # Восстанавливаем переменную итерации
            mov [rdx + 8 * r8], rbx         # Записываем в память со сдвигом полученное число *(array + 8 * i) = element

            # Увеличиваем переменную цикла
            inc qword ptr[rbp - 16]
            jmp loop_read_start
        loop_read_end:

        # Восстанавливаем переданные в функцию аргументы и возвращаем указатель на заполненный массив в rax
        mov rdi, qword ptr[rbp - 32]
        mov rax, qword ptr[rbp - 8]
        leave
        ret

    transform_array:
        # Сохраняем указатель стэка
        push rbp
        mov rbp, rsp

        # Выделим память под размер массива, указатель на старый и новый массивы
        sub rsp, 24
        mov qword ptr[rbp - 24], rsi    # Размер массива
        mov qword ptr[rbp - 16], rdi    # Указатель на старый массив
        mov qword ptr[rbp - 8], 0       # Указатель на новый массив

        # Умножим размер массива на 8 и получим размер в байтах для malloc
        mov rax, rsi
        mov rbx, 8
        mul rbx

        # Выделяем память через malloc
        mov rdi, rax
        call malloc@plt

        # Сохраняем указатель
        mov qword ptr[rbp - 8], rax

        mov rcx, 1 # Переменная цикла по старому массиву
        mov rbx, 0 # Переменная цикла по новому массиву
        mov rdx, qword ptr[rbp - 24] # Размер массива
        loop_odd_start:
            # Сравнение переменных цикла с размером, если хотя бы одна из них >= размера, то прыжок на конец
            cmp rcx, rdx
            cmp rbx, rdx
            jge loop_odd_end

            mov r8, qword ptr[rbp - 16]         # Перемещаем указатель на старый массив
            mov r9, qword ptr[rbp - 8]          # Перемещаем указатель на новый массив
            mov r10, qword ptr[r8 + 8 * rcx]    # Перемещаем текущий элемент
            mov qword ptr[r9 + 8 * rbx], r10    # Заменяем элемент в новом массиве *(new_array + 8 * i) = element

            # Увеличиваем переменные итерации
            inc rbx
            add rcx, 2
            jmp loop_odd_start
        loop_odd_end:

        # Обновляем индекс итерации по старому массиву
        mov rdx, 0
        mov rax, qword ptr[rbp - 24]
        mov rcx, 2
        div rcx

        mov rcx, 0 # Индекс итерации по старому массиву
        mov rbx, rax # Индекс итерации по новому массиву (середина нового массива)
        mov rdx, qword ptr[rbp - 24] # Размер массива
        loop_even_start:
            # Сравнение переменных цикла с размером, если хотя бы одна из них >= размера, то прыжок на конец
            cmp rcx, rdx
            cmp rbx, rdx
            jge loop_even_end

            mov r8, qword ptr[rbp - 16]         # Перемещаем указатель на старый массив
            mov r9, qword ptr[rbp - 8]          # Перемещаем указатель на новый массив
            mov r10, qword ptr[r8 + 8 * rcx]    # Перемещаем текущий элемент
            mov qword ptr[r9 + 8 * rbx], r10    # Заменяем элемент в новом массиве *(new_array + 8 * i) = element

            # Увеличиваем переменные итерации
            inc rbx
            add rcx, 2
            jmp loop_even_start
        loop_even_end:

        # Восстанавливаем переданные в функцию аргументы и возвращаем указатель на новый массив в rax
        mov rdi, qword ptr[rbp - 16]
        mov rsi, qword ptr[rbp - 24]
        mov rax, qword ptr[rbp - 8]

        leave
        ret

    print_array:
        push rbp
        mov rbp, rsp

        # Выделим память под указатель на строку перед массивом, указатель на массив, его размер и переменную цикла
        sub rsp, 32
        mov qword ptr[rbp - 32], rdx    # Указатель на строку перед массивом
        mov qword ptr[rbp - 24], rdi    # Указатель на массив
        mov qword ptr[rbp - 16], rsi    # Размер массива
        mov qword ptr[rbp - 8], 0       # Переменная цикла

        # Выводим сообщение перед массивом
        mov rdi, qword ptr[rbp - 32]
        mov eax, 0
        call printf@plt

        loop_print_start:
            # Сравнение переменной цикла с размером, если >= размера, то прыжок на конец
            mov rcx, qword ptr[rbp - 8]
            mov rdx, qword ptr[rbp - 16]
            cmp rcx, rdx
            jge loop_print_end

            mov r8, qword ptr[rbp - 24]     # Перемещаем указатель на массив
            mov r9, qword ptr[r8 + 8 * rcx] # Перемещаем элемент на позиции *(array + 8 * i) и кладем в r9

            # Выводим элемент на экран с нужным форматированием
            lea rdi, format_output_uint64[rip]
            mov rsi, r9
            mov eax, 0
            call printf@plt

            # Увеличиваем переменную цикла
            inc qword ptr[rbp - 8]
            jmp loop_print_start
        loop_print_end:

        # Заканчиваем вывод '\n'
        lea rdi, output_array_end[rip]
        mov eax, 0
        call printf@plt

        # Восстанавливаем переданные в функцию агрументы
        mov rdi, qword ptr[rbp - 24]
        mov rsi, qword ptr[rbp - 16]
        mov rdx, qword ptr[rbp - 32]

        leave
        ret

    main:
        push rbp
        mov rbp, rsp

        # Выделение памяти под локальные переменные
        # Размер массива, указатель на введенный массив, указатель на новый массив
        # Для сохранения состояния стэка нужно 8 байт, для всего остального 24, значит выделяем 32 байта
        sub rsp, 32

        # Выводим подсказку о вводе размера массива
        lea rdi, msg_input_size[rip]
        mov eax, 0
        call printf@plt

        # Вводим размер массива с консоли
        lea rdi, format_input_uint64[rip]
        lea rsi, qword ptr[rbp - 24]
        mov eax, 0
        call scanf@plt

        # Вызываем read_array, получаем в rax указатель на массив
        mov rdi, qword ptr[rbp - 24]
        call read_array

        # Сохраняем указатель на введенный массив на стэк
        mov qword ptr[rbp - 16], rax

        mov rdi, qword ptr[rbp - 16] # Указатель на массив
        mov rsi, qword ptr[rbp - 24] # Размер массива
        call transform_array

        # Сохраняем указатель на трансформированный массив на стэк
        mov qword ptr[rbp - 8], rax

        # Печатаем новый массив
        mov rdi, qword ptr[rbp - 8]
        mov rsi, qword ptr[rbp - 24]
        lea rdx, output_array_transformed[rip]
        call print_array

        # Печаатаем старый массив
        mov rdi, qword ptr[rbp - 16]
        mov rsi, qword ptr[rbp - 24]
        lea rdx, output_array_initial[rip]
        call print_array

        # Удаляем исходный массив
        mov rdi, qword ptr[rbp - 16]
        call free@plt

        # Удаляем трансформированный массив
        mov rdi, qword ptr[rbp - 8]
        call free@plt

        mov	rax, 0
        leave
        ret