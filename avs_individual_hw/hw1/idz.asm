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

    new_line:
        .string "\n"

    format_output_qword:
        .string "%lld "

    format_input_qword:
        .string "%lld"

.text
    .global  main                               # Обозначаем entry point
    .type   main, @function                     
    .type   read_array, @function
    .type   transform_array, @function
    .type   print_array, @function

    read_array:
        push rbp                                # Пролог
        mov rbp, rsp

        push rdi                                # Сохраняем rdi на стэк
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r12 на стэк (callee-saved register)
        mov r13, rdi                            # Сохраняем переданный размер в r13
        
        sal rdi, 3                              # Умножаем переданный размер на 8 битовым сдвигом влево
        call malloc@plt                         # Выделяем память через malloc
        mov rbx, rax                            # Сохраняем указатель на выделенную память в rbx

        xor r12, r12
        loop_read_start:
            cmp r12, r13                        # Сравнение переменной цикла с размером
            jge loop_read_end                   # Если переменная цикла >= размера, то прыгаем на конец цикла

            lea rdi, input_element[rip]         # Кладем в rdi указатель на подсказку для ввода
            xor eax, eax                        # Нулим rax перед вызовом printf
            call printf@plt                     # Выводим подсказку для ввода числа

            lea rdi, format_input_qword[rip]    # Кладем в rdi указатель на форматирование числа
            lea rsi, [rbx + 8 * r12]            # Передаем указатель на элемент массива, в который нужно произвести запись числа
            xor eax, eax                        # Нулим rax перед вызовом scanf
            call scanf@plt                      # Вводим число

            inc r12
            jmp loop_read_start
        loop_read_end:
        mov rax, rbx                            # Устаналиваем возвращаемое значение (кладем указатель на массив в rax)

        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию (оптимизируем последующие вызовы)
        
        leave                                   # Эпилог
        ret

    transform_array:
        push rbp                                # Пролог
        mov rbp, rsp
        
        push rdi                                # Сохраняем rdi на стэк    
        push rsi                                # Сохраняем rsi на стэк
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)
        push r14                                # Сохраняем r14 на стэк (callee-saved register)
        push r15                                # Сохраняем r15 на стэк (callee-saved register)
        
        mov rbx, rdi                            # Кладем указатель на введенный массив в rbx 
        mov r15, rsi                            # Кладем размер массива в r15 
                                
        mov rdi, rsi                            # Кладем размер массива в rdi (первый аргумент malloc)
        sal rdi, 3                              # Умножаем размер массива на 8 битовым сдвигом влево (получим кол-во байт которое нам нужно выделить)           
        call malloc@plt                         # Вызываем malloc
        mov r12, rax                            # Сохраняем указатель на новый массив, полученный после вызова malloc   

        mov r13, 1                              # Ставим переменную цикла по старому массива равной 1 (идем по нечетным индексам)
        xor r14d, r14d                          # Зануляем переменную цикла по новому массиву (сначала записываем нечетные элементы)
        loop_odd_start:
            cmp r13, r15                        # Сравнение переменной цикла по старому массиву с его размером
            cmp r14, r15                        # Сравнение переменной цикла нового массива с его размером
            jge loop_odd_end                    # Если хотя бы одна из переменных цикла >= размера массива, то прыгаем на конец цикла

            mov r8, qword ptr[rbx + 8 * r13]    # Перемещаем в r8 значение старого массива на позиции r13 <=> element = *((qword*)(rbx + 8 * r13))
            mov qword ptr[r12 + 8 * r14], r8    # Перемещаем значение из r8 в новый массив на позицию r14 <=> *((qword*)(r12 + 8 * r14)) = r8

            add r13, 2                          # Смещаем переменную цикла по старому массиву на следующее нечетное число     
            inc r14                             # Увеличиваем переменную цикла по новому массиву на один
            jmp loop_odd_start                  # Прыгаем на начало цикла
        loop_odd_end:

        xor r13d, r13d                          # Зануляем переменную цикла по старому массиву (теперь идем по четным индексам)
        mov r14, r15                            # Перемещаем размер в переменную цикла по новому массиву
        sar r14, 1                              # Целочисленно делим на два размер массива побитовым сдвигом (мы заполнили [половину] массива элементами на нечетных индексах)

        loop_even_start:
            cmp r13, r15                        # Сравнение переменной цикла по старому массиву с его размером
            cmp r14, r15                        # Сравнение переменной цикла нового массива с его размером
            jge loop_even_end                   # Если хотя бы одна из переменных цикла >= размера массива, то прыгаем на конец цикла

            mov r8, qword ptr[rbx + 8 * r13]    # Перемещаем в r8 значение старого массива на позиции r13 <=> element = *((qword*)(rbx + 8 * r13))
            mov qword ptr[r12 + 8 * r14], r8    # Перемещаем значение из r8 в новый массив на позицию r14 <=> *((qword*)(r12 + 8 * r14)) = r8

            add r13, 2                          # Смещаем переменную цикла по старому массиву на следующее четное число     
            inc r14                             # Увеличиваем переменную цикла по новому массиву на один
            jmp loop_even_start                 # Прыгаем на начало цикла
        loop_even_end:
            
        pop r15                                 # Восстанавливаем r15 к изначальному состоянию
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rsi                                 # Восстанавливаем rsi к изначальному состоянию (оптимизируем последующие вызовы)
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию (оптимизируем последующие вызовы)

        leave                                   # Эпилог
        ret

    print_array:
        push rbp                                # Пролог
        mov rbp, rsp
        push rdi                                # Сохраняем rdi на стэк
        push rsi                                # Сохраняем rsi на стэк
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)

        mov rbx, rdi                            # Сохраняем указатель на массив в rbx
        mov r13, rsi                            # Сохраняем размер массива в r13

        mov rdi, rdx                            # Кладем указатель на сообщение перед выводом в rdi
        xor eax, eax                            # Нулим rax перед вызовом printf
        call printf@plt                         # Выводим сообщение в консоль

        xor r12, r12                            # Задаем переменную цикла равную 0
        loop_print_start:
            cmp r12, r13                        # Сравнение переменной цикла с размером
            jge loop_print_end                  # Если переменная цикла >= размера, то прыгаем на конец цикла

            lea rdi, format_output_qword[rip]   # Кладем указатель на форматирование вывода числа в rdi
            mov rsi, qword ptr[rbx + 8 * r12]   # Кладем число на позиции r12 в массиве в rsi, эквивалентно rsi = *((qword*)(rbx + 8 * r12))
            xor eax, eax                        # Нулим rax перед вызовом printf
            call printf@plt                     # Выводим число в консоль

            inc r12                             # Увеличиваем переменную цикла
            jmp loop_print_start                # Прыгаем на начало цикла
        loop_print_end:

        lea rdi, new_line[rip]                  # Кладем указатель на '\n' в rdi
        xor eax, eax                            # Нулим rax перед вызовом printf
        call printf@plt                         # Выводим '\n' в консоль
        
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rsi                                 # Восстанавливаем rsi к изначальному состоянию (оптимизируем последующие вызовы)
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию (оптимизируем последующие вызовы)

        xor eax, eax                            # Нулим rax как показатель того, что функция отработала успешно
        leave                                   # Эпилог
        ret

    main:
        push rbp                                # Пролог
        mov rbp, rsp
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)

        lea rdi, msg_input_size[rip]            # Передаем подсказку для ввода размера массива
        call printf@plt                         # Выводим подсказку о вводе размера массива

        lea rdi, format_input_qword[rip]        # Передаем форматирование числа (первый аргумент)
        mov rsi, rsp                            # Указатель на место в памяти, куда нужно записать число (второй аргумент)
        call scanf@plt                          # Вызываем scanf c указанными аргументами (вводим размер массива с консоли)

        mov rdi, qword ptr[rsp]                 # Кладем размер массива в rdi
        cmp rdi, 0                              # Сравниваем размер массива с нулем
        jle main_final                          # Если размер <= 0, то прыгаем в конец

        call read_array                         # Вызываем read_array, получаем в rax указатель на заполненный массив

        mov rsi, rdi                            # Перемещаем размер массива в rsi, откуда последующие функции берут размер
        mov rdi, rax                            # Кладем указатель на введенный массив в rdi
        call transform_array                    # Вызываем функцию, которая сначала ставит элементы с нечетными индексами, а потом с четными

        mov rbx, rdi                            # Сохраняем указатель на введеный массив в rbx
        mov rdi, rax                            # Кладем в rdi указатель на трансформированный массив
        lea rdx, output_array_transformed[rip]  # Форматирование перед выводом трансформированного массива
        call print_array                        # Печатаем трансформированный массив

        mov r12, rdi                            # Сохраняем указатель на трансформированный массив в r12
        mov rdi, rbx                            # Кладем указатель на старый массив в rdi
        lea rdx, output_array_initial[rip]      # Форматирование перед выводом старого массива
        call print_array                        # Печатаем старый массив

        call free@plt                           # Удаляем введенный массив
        mov rdi, r12                            # Кладем указатель на трансформированный массив в rdi
        call free@plt                           # Удаляем трансформированный массив

        main_final:
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        
        xor eax, eax                            # Нулим rax как показатель корректного завершения работы программы
        leave
        ret