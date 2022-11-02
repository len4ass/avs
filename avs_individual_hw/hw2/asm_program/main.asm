.intel_syntax noprefix
.include "rodata.asm"
.include "read_string.asm"
.include "sequence.asm"
.include "generate_string.asm"

.text
    .global main                                # Обозначаем entry point
    .type   main, @function                     
    .type   run_console, @function
    .type   run_files, @function   
    .type   run_random_generated, @function
    
    run_console:
        push rbp                                # Пролог
        mov rbp, rsp                            
        
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        push r13
        push r14
        sub rsp, 16
    
        lea rdi, console_seq_len[rip]           # Передаем указатель на подсказку для размера искомой последовательности
        call printf@plt                         # Выводим подсказку

        lea rdi, format_input_qword[rip]        # Передаем форматирование числа (первый аргумент)
        lea rsi, qword ptr[rsp - 16]            # Указатель на место в памяти, куда нужно записать число (второй аргумент)
        xor eax, eax
        call scanf@plt                          # Вызываем scanf c указанными аргументами
        mov r13, qword ptr[rsp - 16]
        
        call getchar@plt                        # Скармливаем '\n', иначе оно попадет при чтении
        
        mov rdi, r13                            # Перемещаем длину последовательности, которая нам нужна, в rdi
        cmp rdi, 0                              # Сравниваем с 0
        jle .invalid_seq_len                    # Если длина <= 0, то прыгаем на метку invalid_seq_len
        
        lea rdi, console_read_string[rip]       # Кладем в rdi указатель на строку подсказку для ввода строки
        call printf@plt                         # Выводим подсказку
        
        xor edi, edi                            # Кладем 0 в rsi, как показатель того, что чтение строки должно производиться с консоли
        call read_string                        # Вызываем функцию чтения строки
        
        mov rbx, rax                            # Сохраняем указатель считанной строки в rbx
        mov r14, rdx                            # Сохраняем размер строки в r14
        
        cmp rax, 0                              # Сравниваем указатель с 0 (NULL)
        je .invalid_string                      # Если указатель на строку равен 0, то прыгаем на метку invalid_string
        
        cmp r13, r14                            # Сравниваем длину искомой последовательности и размер строки
        jg .invalid_seq_len_greater             # Если длина искомой последовательности больше размера строки, то прыгаем на метку invalid_seq_len_greater

        mov rdi, rbx                            # Кладем указатель на строку в rdi
        mov rsi, r14                            # Кладем размер строки в rsi
        mov rdx, r13                            # Кладем длину искомой последовательности в rdx
        call find_sequence                      # Вызываем функцию, которая ищет валидную последовательность указанной длины в строке
        
        mov r12, rax                            # Сохраняем указатель на последовательность в r12
        cmp rax, 0                              # Сравниваем указатель с 0 (NULL)
        je .sequence_not_found                  # Если указатель на последовательность равен 0, то прыгаем на метку sequence_not_found
        
        lea rdi, console_found_seq[rip]         # Кладем в rdi форматирование для выводимой последовательности
        mov rsi, r12                            # Кладем в rsi указатель на последовательность
        call printf@plt                         # Выводим последовательность
        
        mov rdi, rbx                            # Кладем в rdi указатель на строку для вызова free
        call free@plt                           # Высвобождаем память
        jmp .free_seq                           # Прыгаем на метку free_seq
        
        .sequence_not_found:
        lea rdi, console_notfound_seq[rip]      # Кладем в rdi подсказку о том, что последовательность указанной длины не найдена
        call printf@plt                         # Выводим подсказку
        jmp .free_string                        # Прыгаем на метку free_string
        
        .invalid_seq_len_greater:
        lea rdi, console_invalid_seq_len_g[rip] # Кладем в rdi подсказку о том, что последовательность длины большей чем строка не валидна
        call printf@plt                         # Выводим подсказку
        jmp .free_string                        # Прыгаем на метку free_string
       
        .invalid_string:    
        lea rdi, console_invalid_string[rip]    # Кладем в rdi подсказку о том, что введенная строка пустая
        call printf@plt                         # Выводим подсказку
        jmp .run_console_final                  # Прыгаем на метку run_console_final
        
        .invalid_seq_len:
        lea rdi, console_invalid_seq_len[rip]   # Кладем в rdi подсказку о том, что длина искомой последовательности не может быть <= 0
        call printf@plt                         # Выводим подсказку
        jmp .run_console_final                  # Прыгаем на метку run_console_final
        
        .free_string:
        mov rdi, rbx                            # Кладем в rdi указатель на строку для вызова free                  
        call free@plt                           # Высвобождаем память
        jmp .run_console_final                  # Прыгаем на метку run_console_final
        
        .free_seq:
        mov rdi, r12                            # Кладем в rdi указатель на последовательность для вызова free
        call free@plt                           # Высвобождаем память
        jmp .run_console_final                  # Прыгаем на метку run_console_final
        
        .run_console_final:
        
        add rsp, 16
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        leave 
        ret
            
    run_files:
        push rbp                                # Пролог
        mov rbp, rsp                            
        
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        push r13                                # Сохраняем r13 (callee-saved register)
        push r14                                # Сохраняем r14 (callee-saved register)
        push r15                                # Сохраняем r15 (callee-saved register)                            
        sub rsp, 24
        
        mov r13, rdi                            # Сохраняем указатель на имя файла ввода
        mov r14, rsi                            # Сохраняем указатель на имя файла вывода
    
        lea rsi, file_read[rip]                 # Передаем указатель на флаг "r" в rdi
        call fopen@plt                          # Открываем поток
        
        mov r15, rax                            # Сохраняем указатель на поток к файлу
        cmp rax, 0                              # Сраниваем указатель с 0 (NULL)
        je .files_failed_read                   # Прыгаем на метку files_failed_read, если указатель NULL

        mov rdi, r15                            # Передаем указатель на поток к файлу
        lea rsi, format_output_qword[rip]       # Передаем указатель на форматирование ввода
        lea rdx, qword ptr[rsp - 16]            # Указатель на место в памяти, куда нужно записать число (второй аргумент)
        xor eax, eax
        call fscanf@plt                         # Вызываем scanf c указанными аргументами
        
        mov rdi, qword ptr[rsp - 16]            # Перемещаем длину последовательности, которая нам нужна, в rdi
        cmp rdi, 0                              # Сравниваем с 0
        jle .files_invalid_seq_len              # Если длина <= 0, то прыгаем на метку files_invalid_seq_len
        
        mov rdi, r15                            # Кладем в rdi указатель на поток к файлу, из которого будет производиться чтение
        call read_string                        # Вызываем функцию чтения строки
            
        mov rbx, rax                            # Сохраняем указатель считанной строки в rbx
        mov qword ptr[rsp - 8], rdx             # Сохраняем размер строки на стэк
        
        mov rdi, r15                            # Кладем указатель на поток к файлу в rdi
        call fclose@plt                         # Закрываем поток
        
        cmp rbx, 0                              # Сравниваем указатель на строку с 0 (NULL)
        je .files_invalid_string                # Прыгаем на метку files_invalid_string, если указатель NULL
        
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi длину искомой последовательности
        mov rsi, qword ptr[rsp - 8]             # Кладем в rsi размер строки
        cmp rdi, rsi                            # Сравниваем длину искомой последовательности и размер строки
        jg .files_invalid_seq_len_greater       # Если длина искомой последовательности больше размера строки, то прыгаем на метку files_invalid_seq_len_greater

        mov rdi, rbx                            # Кладем указатель на строку в rdi
        mov rsi, qword ptr[rsp - 8]             # Кладем размер строки в rsi
        mov rdx, qword ptr[rsp - 16]            # Кладем длину искомой последовательности в rdx
        call find_sequence                      # Вызываем функцию, которая ищет валидную последовательность указанной длины в строке
        
        mov r12, rax                            # Сохраняем указатель на последовательность в r12
        cmp rax, 0                              # Сравниваем указатель с 0 (NULL)
        je .files_sequence_not_found            # Если указатель на последовательность равен 0, то прыгаем на метку files_sequence_not_found
        
        mov rdi, r14                            # Кладем указатель на строку к файлу вывода в rdi
        lea rsi, file_write[rip]                # Кладем флаг "w" в rsi
        call fopen@plt                          # Открываем поток к файлу
        mov r15, rax                            # Сохраняем поток к файлу вывода
        
        mov rdi, rax                            # Кладем в rdi указатель на поток к файлу вывода
        lea rsi, format_string[rip]             # Кладем в rsi указатель на формат вывода строки
        mov rdx, r12                            # Кладем в rdx указатель на последовательность
        call fprintf@plt
        
        mov rdi, r15                            # Кладем в rdi указатель на поток к файлу вывода
        call fclose@plt                         # Закрываем поток к файлу вывода
        
        mov rdi, rbx                            # Кладем в rdi указатель на строку для вызова free
        call free@plt                           # Высвобождаем память
        jmp .files_free_seq                     # Прыгаем на метку files_free_seq
        
        .files_failed_read:
        lea rdi, file_failed_reading[rip]       # Кладем подсказку о том, что не удалось чтение из файла
        call printf@plt                         # Выводим подсказку
        jmp .run_files_final                    # Прыгаем на метку run_files_final
        
        .files_sequence_not_found:
        lea rdi, console_notfound_seq[rip]      # Кладем в rdi подсказку о том, что последовательность указанной длины не найдена
        call printf@plt                         # Выводим подсказку
        jmp .files_free_string                  # Прыгаем на метку files_free_string
        
        .files_invalid_seq_len_greater:
        lea rdi, console_invalid_seq_len_g[rip] # Кладем в rdi подсказку о том, что последовательность длины большей чем строка не валидна
        call printf@plt                         # Выводим подсказку
        jmp .files_free_string                  # Прыгаем на метку files_free_string
       
        .files_invalid_string:    
        lea rdi, console_invalid_string[rip]    # Кладем в rdi подсказку о том, что введенная строка пустая
        call printf@plt                         # Выводим подсказку
        jmp .run_files_final                    # Прыгаем на метку run_files_final
        
        .files_invalid_seq_len:
        lea rdi, console_invalid_seq_len[rip]   # Кладем в rdi подсказку о том, что длина искомой последовательности не может быть <= 0
        call printf@plt                         # Выводим подсказку
        
        mov rdi, r15                            # Кладем в rdi указатель на поток к файлу
        call fclose@plt                         # Закрываем поток к файлу
        jmp .run_files_final                    # Прыгаем на метку run_files_final
        
        .files_free_string:
        mov rdi, rbx                            # Кладем в rdi указатель на строку для вызова free                  
        call free@plt                           # Высвобождаем память
        jmp .run_files_final                    # Прыгаем на метку run_files_final
        
        .files_free_seq:
        mov rdi, r12                            # Кладем в rdi указатель на последовательность для вызова free
        call free@plt                           # Высвобождаем память
        
        .run_files_final:
        
        add rsp, 24
        pop r15                                 # Восстанавливаем r15 к изначальному состоянию
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        leave 
        ret
        
    run_random_generated:
        push rbp                                # Пролог
        mov rbp, rsp
                
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        sub rsp, 16
        
        mov qword ptr[rsp - 16], rdi            # Сохраняем размер генерируемой строки
        mov qword ptr[rsp - 8], rsi             # Сохраняем длину искомой последовательности
        
        cmp rdi, 0                              # Сравниваем размер генерируемой строки с 0
        jl .run_random_generated_final          # Если < 0, прыгаем на метку run_random_generated_final
        
        cmp rsi, 0                              # Сравниваем длину искомой последовательности с 0
        jl .run_random_generated_final          # Если < 0, прыгаем на метку run_random_generated_final
       
        mov rdi, qword ptr[rsp - 16]            # Передаем размер сгенерированной строки
        mov rsi, qword ptr[rsp - 8]             # Передаем размер искомой последовательности
        call generate_string
        
        mov rbx, rax                            # Сохраняем указатель на строку в rbx
        mov qword ptr[rsp - 16], rdx            # Сохраняем размер строки
        mov qword ptr[rsp - 8], rcx             # Сохраняем длину последовательности
        
        mov rdi, qword ptr[rsp - 16]            
        mov rsi, qword ptr[rsp - 8]
        cmp rsi, rdi                            # Сравниваем длину последовательности и размер строки
        jg .random_string_smaller               # Если длина последовательности больше размера строки, то прыгаем на метку random_string_smaller
        
        mov rdi, rbx                            # Кладем указатель на строку в rdi
        mov rsi, qword ptr[rsp - 16]            # Кладем размер строки в rsi
        mov rdx, qword ptr[rsp - 8]             # Кладем длину последовательности в rdx
        call find_sequence                      # Вызываем функцию, которая ищет валидную последовательность указанной длины в строке
        
        mov r12, rax                            # Сохраняем указатель на последовательность в r12
        
        cmp rax, 0                              # Сраниваем указатель на последовательность с 0 (NULL)
        je .random_notfound_seq                 # Если указатель NULL, то прыгаем на метку random_notfound_seq
        
        lea rdi, generated_file_name[rip]       # Кладем указатель на имя файла для сгенерированной строки
        lea rsi, file_write[rip]                # Кладем указатель на флаг "w"
        call fopen@plt                          # Открываем поток к файлу
        mov qword ptr[rsp - 16], rax            # Сохраняем указатель на поток к файлу 
            
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi указатель на поток к файлу
        lea rsi, format_string[rip]             # Кладем в rsi указатель на форматирование строки
        mov rdx, rbx                            # Кладем в rdx указатель на строку
        call fprintf@plt                        # Выводим в файл строку
        
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi указатель на поток к файлу
        call fclose@plt                         # Закрываем поток к файлу
        
        lea rdi, generated_seq_file_name[rip]   # Кладем указатель на имя файла для найденной последовательности
        lea rsi, file_write[rip]                # Кладем указатель на флаг "w"
        call fopen@plt                          # Открываем поток к файлу
        
        mov qword ptr[rsp - 16], rax            # Сохраняем указатель на поток к файлу 
        
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi указатель на поток к файлу
        lea rsi, format_string[rip]             # Кладем в rsi указатель на форматирование последовательности
        mov rdx, r12                            # Кладем в rdx указатель на последовательность
        call fprintf@plt                        # Выводим в файл последовательность
        
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi указатель на поток к файлу
        call fclose@plt                         # Закрываем поток к файлу
        
        mov rdi, rbx                            # Кладем в rdi указатель на строку
        call free@plt                           # Высвобождаем память
        
        mov rdi, r12                            # Кладем в rdi указатель на последовательность
        call free@plt                           # Высвобождаем память

        jmp .run_random_generated_final         # Прыгаем на метку run_random_generated_final
        
        .random_string_smaller:
        lea rdi, generate_string_smalller_size[rip] # Кладем в rdi подсказку о том, что размер строки меньше длины последовательностти
        call printf@plt                         # Выводим подсказку
        
        mov rdi, rbx                            # Перемещаем указатель на строку в rdi
        call free@plt                           # Высвобождаем память 
        jmp .run_random_generated_final         # Прыгаем на метку run_random_generated_final
        
        .random_notfound_seq:
        lea rdi, generate_seq_not_found[rip]    # Кладем в rdi указатель на подсказку о том, что не удалось найти последовательность указанной длины
        call printf@plt                         # Выводим подсказку
        
        mov rdi, rbx                            # Кладем в rdi указатель на строку 
        call free@plt                           # Высвобождаем память
        jmp .run_random_generated_final         # Прыгаем на метку run_random_generated_final
        
        .random_wrong_size:
        lea rdi, generate_wrong_size[rip]       # Кладем подсказку в rdi о том, что генерация не удалась
        call printf@plt                         # Выводим подсказку
        jmp .run_random_generated_final         # Прыгаем на метку run_random_generated_final
        
        .generate_failed:
        lea rdi, generated_failed[rip]          # Сообщение о неудачном чтении массива с консоли
        xor eax, eax                            # Нулим rax
        call printf@plt                         # Выводим сообщение в консоль
        
        .run_random_generated_final:
        add rsp, 16
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        
        leave
        ret

    main:
        push rbp                                # Пролог
        mov rbp, rsp
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)
        sub rsp, 16
        
        xor r12d, r12d
        mov r12d, edi                           # Размер массива аргументов командной строки
        mov r13, rsi                            # Указатель размера аргументов командной строки
        
        cmp r12d, 2                             # Проверяем равно ли число аргументов 2 (-g)
        je .generate_all_mode                   # Если равно, то прыгаем на метку где происходит генерация строки вместе с длиной последовательности
        
        cmp r12d, 3                             # Проверяем равно ли число аргументов 3 (-g value)
        je .generate_by_size_mode               # Если равно, то прыгаем на метку где происходит генерация строки по заданному размеру
        
        cmp r12d, 4                             # Проверяем равно ли число аргументов 4 
        je .check_mode                          # Если равно, то прыгаем на метку где происходит проверка режима
        
        .console_mode:
        call run_console                        # Ввод с консоли, поиск последовательности, вывод в консоль
        jmp .main_final                         # Прыжок в конец функции
            
        .check_mode:
        mov rdi, [r13 + 8]                      # Кладем argv[1] в rdi
        lea rsi, flag_file[rip]                 # Кладем "-f" в rsi
        call strcmp@plt                         # Сравниваем строки
        
        cmp rax, 0                              # Проверяем результат сравнения
        jne .generate_by_given_data             # Прыгаем на метку generate_by_given_data, если argv[1] != "-f"
        
        mov rdi, [r13 + 16]                     # Кладем в rdi указатель на строку с именем входного файла (первый аргумент)
        mov rsi, [r13 + 24]                     # Кладем в rsi указатель на строку с именем выходного файла (второй аргумент)
        call run_files                          # Ввод из файла, преобразование, вывод в файл
        jmp .main_final
        
        .generate_by_given_data:
        mov rdi, [r13 + 16]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, format_input_qword[rip]        # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 16]            # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
        
        mov rdi, [r13 + 24]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, format_input_qword[rip]        # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 8]             # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
        
        mov rdi, qword ptr[rbp - 16]            # Кладем в rdi размер для строки
        mov rsi, qword ptr[rbp - 8]             # Кладем в rsi длину для последовательности
        call run_random_generated               # Генерация строки указанного размера и поиск последовательности указанной длины
        jmp .main_final                         # Прыгаем на метку main_final
        
        .generate_all_mode:
        xor edi, edi                            # Нулим rdi как показатель того, что размер строки нужно сгенерировать
        xor esi, esi                            # Нулим rsi как показатель того, что длину последовательности нужно сгенерировать
        call run_random_generated               # Генерация строки, поиск последовательности и вывод
        jmp .main_final                         # Прыгаем на метку main_final
        
        .generate_by_size_mode:
        mov rdi, [r13 + 16]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, format_input_qword[rip]        # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 16]            # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
            
        mov rdi, qword ptr[rbp - 16]            # Кладем полученное число в rdi
        call run_random_generated               # Генерация строки по заданному размеру, генерация длины искомой последовательности и вывод

        .main_final:  
        
        add rsp, 16
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        
        xor eax, eax                            # Нулим rax как показатель корректного завершения работы программы
        leave
        ret