.intel_syntax noprefix
.include "rodata.asm"
.include "generate_double.asm"
.include "integrate.asm"

.text
    .global main                                # Обозначаем entry point
    .type   main, @function                     
    .type   run_console, @function
    .type   run_files, @function   
    .type   run_random_generated, @function
    
    run_console:
        push rbp                                # Пролог
        mov rbp, rsp                            
        sub rsp, 48
    
        lea rdi, input_coeff_a[rip]             # Передаем указатель на подсказку ввода для коэффициента а
        call printf@plt                         # Выводим подсказку
        
        lea rdi, input_scan_double[rip]         # Передаем указатель на форматирование double
        lea rsi, qword ptr[rbp - 40]            # Передаем указатель на память, куда следует записать число
        xor eax, eax                            # Нулим rax
        call scanf@plt                          # Вызываем scanf с указанными аргументами
        
        lea rdi, input_coeff_b[rip]             # Передаем указатель на подсказку ввода для коэффициента b
        call printf@plt                         # Выводим подсказку
        
        lea rdi, input_scan_double[rip]         # Передаем указатель на форматирование double
        lea rsi, qword ptr[rbp - 32]            # Передаем указатель на память, куда следует записать число
        xor eax, eax                            # Нулим rax
        call scanf@plt                          # Вызываем scanf с указанными аргументами
        
        lea rdi, input_integral_lower_bound[rip]# Передаем указатель на подсказку ввода для нижнего предела интегрирования
        call printf@plt                         # Выводим подсказку
        
        lea rdi, input_scan_double[rip]         # Передаем указатель на форматирование double
        lea rsi, qword ptr[rbp - 24]            # Передаем указатель на память, куда следует записать число
        xor eax, eax                            # Нулим rax
        call scanf@plt                          # Вызываем scanf с указанными аргументами
        
        lea rdi, input_integral_upper_bound[rip]# Передаем указатель на подсказку ввода для верхнего предела интегрирования
        call printf@plt                         # Выводим подсказку
        
        lea rdi, input_scan_double[rip]         # Передаем указатель на форматирование double
        lea rsi, qword ptr[rbp - 16]             # Передаем указатель на память, куда следует записать число
        xor eax, eax                            # Нулим rax
        call scanf@plt                          # Вызываем scanf с указанными аргументами

        movsd xmm2, qword ptr[rbp - 24]          # Кладем в xmm2 нижний предел интегрирования
        movsd xmm3, qword ptr[rbp - 16]           # Кладем в xmm3 верхний предел интегрирования
        comisd xmm2, xmm3                       # Сравниваем пределы интегрирования
        ja .run_console_bounds_error            # Если нижний предел интегрирования больше верхнего, то прыгаем на метку run_console_bounds_error

        movsd xmm0, qword ptr[rbp - 40]          # Кладем в xmm0 коэффициент a
        movsd xmm1, qword ptr[rbp - 32]          # Кладем в xmm1 коэффициент b
        call integrate                          # Интегрируем функцию
        
        lea rdi, output_integral_result[rip]    # Кладем указатель на форматирование вывода в rsi
        mov rax, 1                              # Указываем, что будет производиться работа с вещественными числами
        call printf@plt                         # Выводим результат интегрирования
        jmp .run_console_final
        
        .run_console_bounds_error:
        lea rdi, error_lower_more_than_upper[rip]# Кладем подсказку на ошибку, связанную с пределами интегрирования
        xor eax, eax
        call printf@plt                         # Выводим ошибку
        
        .run_console_final:
        
        add rsp, 48
        leave 
        ret
            
    run_files:
        push rbp                                # Пролог
        mov rbp, rsp                            
        
        push r12                                # Сохраняем r12 (callee-saved register)
        push r13
        push r14  
        push r15                       
        sub rsp, 48
        
        mov r13, rdi                            # Сохраняем указатель на имя файла ввода
        mov r14, rsi                            # Сохраняем указатель на имя файла вывода
    
        lea rsi, file_read_flag[rip]            # Передаем указатель на флаг "r" в rsi
        call fopen@plt                          # Открываем поток
        
        mov r15, rax                            # Сохраняем указатель на поток к файлу
        cmp rax, 0                              # Сраниваем указатель с 0 (NULL)
        je .files_failed_read                   # Прыгаем на метку files_failed_read, если указатель NULL

        mov rdi, r15                            # Передаем указатель на поток к файлу
        lea rsi, file_scan_input[rip]           # Передаем указатель на форматирование ввода с файла
        lea rdx, qword ptr[rbp - 32]            # Указатель на место в памяти, куда нужно записать коэффициент а
        lea rcx, qword ptr[rbp - 24]            # Указатель на место в памяти, куда нужно записать коэффициент b
        lea r8, qword ptr[rbp - 16]             # Указатель на место в памяти, куда нужно записать нижний предел интегрирования
        lea r9, qword ptr[rbp - 8]              # Указатель на место в памяти, куда нужно записать верхний предел интегрирования
        xor eax, eax                            # Нулим rax
        call fscanf@plt                         # Вызываем scanf c указанными аргументами
        
        mov rdi, r15                            # Перемещаем поток ввода в rdi
        call fclose@plt                         # Закрываем поток ввода
        
        movsd xmm2, qword ptr[rbp - 16]         # Кладем в xmm2 нижний предел интегрирования
        movsd xmm3, qword ptr[rbp - 8]          # Кладем в xmm3 верхний предел интегрирования
        comisd xmm2, xmm3                       # Сравниваем пределы интегрирования
        ja .run_files_bounds_error              # Если нижний предел интегрирования больше верхнего, то прыгаем на метку run_files_bounds_error
        
        movsd xmm0, qword ptr[rbp - 32]         # Кладем в xmm0 коэффициент а 
        movsd xmm1, qword ptr[rbp - 24]         # Кладем в xmm1 коэффициент b
        call integrate                          # Интегрируем функцию
        
        movsd qword ptr[rbp - 40], xmm0         # Сохраняем результат интегрирования
        
        mov rdi, r14                            # Передаем указатель на имя файла вывода в rdi
        lea rsi, file_write_flag[rip]           # Передаем указатель на флаг "w" в rsi
        call fopen@plt                          # Открываем поток к файлу вывода
        
        mov r15, rax                            # Сохраняем указатель на поток к файлу
        
        movsd xmm0, qword ptr[rbp - 40]         # Передаем в xmm0 результат интегрирования
        mov rdi, rax                            # Передаем в rdi поток к файлу
        lea rsi, file_print_output[rip]         # Кладем в rsi указатель на форматирование
        mov rax, 1                              # Указываем, что будет производиться работа с 1 вещественным параметром
        call fprintf@plt                        # Выводим результат интегрирования
        
        mov rdi, r15                            # Передаем в rdi указатель на поток к файлу
        call fclose@plt                         # Закрываем поток вывода
        jmp .run_files_final
       
        .files_failed_read:
        lea rdi, error_fopen[rip]               # Кладем подсказку о том, что не удалось чтение из файла
        xor eax, eax
        call printf@plt                         # Выводим подсказку
        jmp .run_files_final                    # Прыгаем на метку run_files_final
        
        .run_files_bounds_error:
        lea rdi, error_lower_more_than_upper[rip]# Кладем подсказку на ошибку, связанную с пределами интегрирования
        xor eax, eax
        call printf@plt                         # Выводим ошибку в консоль
        
        .run_files_final:
        
        add rsp, 48
        pop r15
        pop r14
        pop r13
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        leave 
        ret
        
    run_random_generated:
        push rbp                                # Пролог
        mov rbp, rsp
                
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        sub rsp, 32
        
        movsd qword ptr[rbp - 32], xmm0         # Сохраняем нижний предел интегрирования
        movsd qword ptr[rbp - 24], xmm1         # Сохраняем верхний предел интегрирования
        
        comisd xmm0, xmm1                       # Сравниваем нижний предел интегрирования с верхним
        ja .run_random_bounds_error             # Если нижний больше верхнего, то прыгаем на метку run_random_bounds_error
        
        xor edi, edi                            # Обнуляем rdi
        call time@plt                           # Получаем unix_time
        
        mov rdi, rax                            # Кладем unix time в rdi в качестве сида
        call srand@plt                          # Устанавливаем сид рандома
        
        pxor xmm4, xmm4                         # Нулим xmm4
        movsd xmm0, qword ptr[rbp - 32]
        comisd xmm0, xmm4                       # Сравниваем нижний предел интегрирования с 0
        jnz .run_random_skip_bnd_gen            # Если не равен 0, то скипаем рандом 
        
        pxor xmm4, xmm4                         # Нулим xmm4
        movsd xmm1, qword ptr[rbp - 24]
        comisd xmm1, xmm4                       # Сравниваем верхний предел интегрирования с 1
        jnz .run_random_skip_bnd_gen            # Если не равен 0, то скипаем рандом
        
        pxor xmm0, xmm0                         # Нулим xmm0
        mov rax, 4636737291354636288            # double-representation для 100
        movq xmm1, rax                          # Кладем в xmm1 double-representation 100
        call generate_double                    # Генерируем рандомное число
        movsd qword ptr[rbp - 32], xmm0         # Сохраняем сгенерированный нижний предел интегрирования
        
        mov rax, 4636737291354636288            # double-representation для 100
        movq xmm1, rax                          # Кладем в xmm1 double-representation 100
        call generate_double                    # Генерируем рандомное число
        movsd qword ptr[rbp - 24], xmm0         # Сохраняем сгенерированный верхний предел интегрирования
        
        .run_random_skip_bnd_gen:
        movsd xmm0, qword ptr[rbp - 32]         # Кладем в xmm0 нижний предел интегрирования
        movsd xmm1, qword ptr[rbp - 24]         # Кладем в xmm1 верхний предел интегрирования
        call generate_double                    # Генерируем рандомное число
        movsd qword ptr[rbp - 16], xmm0         # Сохраняем коэффициент а
        
        movsd xmm1, qword ptr[rbp - 24]         # Кладем в xmm1 верхний предел интегрирования
        call generate_double                    # Генерируем рандомной число
        movsd qword ptr[rbp - 8], xmm0          # Сохраняем коэффициент b
        
        lea rdi, random_generated_file_name[rip]# Кладем в rdi указатель на "generated.txt"
        lea rsi, file_write_flag[rip]           # Кладем в rdi указатель на флаг "w"
        call fopen@plt                          # Открываем поток к файлу
            
        mov rbx, rax                            # Сохраняем указатель на поток к файлу в rax
        
        mov rdi, rax                            # Кладем указатель на поток вывода в rdi
        lea rsi, file_print_generated_output[rip]# Кладем указатель на форматирование в rsi 
        movsd xmm0, qword ptr[rbp - 16]         # Кладем в xmm0 коэффициент а  
        movsd xmm1, qword ptr[rbp - 8]          # Кладем в xmm1 коэффициент b
        movsd xmm2, qword ptr[rbp - 32]         # Кладем в xmm2 нижний предел интегрирования
        movsd xmm3, qword ptr[rbp - 24]         # Кладем в xmm3 верхний предел интегрирования
        mov eax, 4                              # Показываем, что мы работаем с 4 вещественными числами
        call fprintf@plt                        # Записываем сгенерированные данные в файл
        
        mov rdi, rbx                            # Кладем указатель на поток к файлу в rdi
        call fclose@plt                         # Закрываем поток к файлу
                    
        movsd xmm0, qword ptr[rbp - 16]         # Кладем в xmm0 коэффициент а  
        movsd xmm1, qword ptr[rbp - 8]          # Кладем в xmm1 коэффициент b
        movsd xmm2, qword ptr[rbp - 32]         # Кладем в xmm2 нижний предел интегрирования
        movsd xmm3, qword ptr[rbp - 24]         # Кладем в xmm3 верхний предел интегрирования
        call integrate
        
        movq r12, xmm0                          # Сохраняем результат интегрирования
        
        lea rdi, random_result_file_name[rip]   # Кладем в rdi указатель на "result.txt"
        lea rsi, file_write_flag[rip]           # Кладем в rdi указатель на "w"
        call fopen@plt                          # Открываем поток к файлу
        
        mov rbx, rax                            # Сохраняем указатель на поток к файлу в rbx
        mov rdi, rax                            # Кладем указатель на поток к файлу в rdi
        lea rsi, file_print_output[rip]         # Кладем в rsi указатель на форматирование вывода
        movq xmm0, r12                          # Кладем в xmm результат интегрирования
        mov eax, 1                              # Показываем, что мы работаем с 1 вещественным числом
        call fprintf@plt
        
        mov rdi, rbx                            # Кладем указатель на поток к файлу в rdi
        call fclose@plt                         # Закрываем поток к файлу
        jmp .run_random_generated_final
                                
        .run_random_bounds_error:
        lea rdi, error_lower_more_than_upper[rip]# Кладем подсказку на ошибку, связанную с пределами интегрирования
        call printf@plt                         # Выводим ошибку в консоль
        
        .run_random_generated_final:
        add rsp, 32
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
        lea rsi, input_scan_double[rip]         # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 16]            # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
        
        mov rdi, [r13 + 24]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, input_scan_double[rip]         # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 8]             # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
        
        movsd xmm0, qword ptr[rbp - 16]         # Кладем в xmm0 upper_bound
        movsd xmm1, qword ptr[rbp - 8]          # Кладем в xmm1 lower_bound
        call run_random_generated               # Генерация строки указанного размера и поиск последовательности указанной длины
        jmp .main_final                         # Прыгаем на метку main_final
        
        .generate_all_mode:
        pxor xmm0, xmm0                         # Нулим rdi как показатель того, что размер строки нужно сгенерировать
        pxor xmm1, xmm1                         # Нулим rsi как показатель того, что длину последовательности нужно сгенерировать
        call run_random_generated               # Генерация строки, поиск последовательности и вывод
        jmp .main_final                         # Прыгаем на метку main_final
        
        .generate_by_size_mode:
        mov rdi, [r13 + 16]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, input_scan_double[rip]         # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 16]            # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
            
        pxor xmm0, xmm0                         # Обнуляем xmm0    
        movsd xmm1, qword ptr[rbp - 16]         # Кладем полученное число в rdi
        call run_random_generated               # Генерация строки по заданному размеру, генерация длины искомой последовательности и вывод

        .main_final:  
        
        add rsp, 16
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        
        xor eax, eax                            # Нулим rax как показатель корректного завершения работы программы
        leave
        ret