.text
    .type   read_array, @function
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
    
        xor r12, r12                            # Зануляем переменную цикла
        .loop_read_start:
            cmp r12, r13                        # Сравнение переменной цикла с размером
            jge .loop_read_end                  # Если переменная цикла >= размера, то прыгаем на конец цикла
    
            lea rdi, input_element[rip]         # Кладем в rdi указатель на подсказку для ввода
            xor eax, eax                        # Нулим rax перед вызовом printf
            call printf@plt                     # Выводим подсказку для ввода числа
    
            lea rdi, format_input_qword[rip]    # Кладем в rdi указатель на форматирование числа
            lea rsi, [rbx + 8 * r12]            # Передаем указатель на элемент массива, в который нужно произвести запись числа
            xor eax, eax                        # Нулим rax перед вызовом scanf
            call scanf@plt                      # Вводим число
    
            inc r12                             # Увеличиваем переменную цикла
            jmp .loop_read_start                # Прыгаем в начало цикла
        .loop_read_end:
        mov rax, rbx                            # Устаналиваем возвращаемое значение (кладем указатель на массив в rax)
    
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
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
        sub rsp, 8                              # Выравнивание cтэка
    
        mov rbx, rdi                            # Сохраняем указатель на массив в rbx
        mov r13, rsi                            # Сохраняем размер массива в r13
    
        mov rdi, rdx                            # Кладем указатель на сообщение перед выводом в rdi
        xor eax, eax                            # Нулим rax перед вызовом printf
        call printf@plt                         # Выводим сообщение в консоль
    
        xor r12, r12                            # Задаем переменную цикла равную 0
        .loop_print_start:
            cmp r12, r13                        # Сравнение переменной цикла с размером
            jge .loop_print_end                 # Если переменная цикла >= размера, то прыгаем на конец цикла
    
            lea rdi, format_output_qword[rip]   # Кладем указатель на форматирование вывода числа в rdi
            mov rsi, qword ptr[rbx + 8 * r12]   # Кладем число на позиции r12 в массиве в rsi, эквивалентно rsi = *((qword*)(rbx + 8 * r12))
            xor eax, eax                        # Нулим rax перед вызовом printf
            call printf@plt                     # Выводим число в консоль
    
            inc r12                             # Увеличиваем переменную цикла
            jmp .loop_print_start               # Прыгаем на начало цикла
        .loop_print_end:
    
        lea rdi, new_line[rip]                  # Кладем указатель на '\n' в rdi
        xor eax, eax                            # Нулим rax перед вызовом printf
        call printf@plt                         # Выводим '\n' в консоль
                
        add rsp, 8                              # Убираем выравнивание
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rsi                                 # Восстанавливаем rsi к изначальному состоянию (оптимизируем последующие вызовы)
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию (оптимизируем последующие вызовы)
    
        leave                                   # Эпилог
        ret