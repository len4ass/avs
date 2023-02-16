.intel_syntax noprefix
.include "rodata.asm"
.include "transform_array.asm"
.include "stdio_array.asm"
.include "fio_array.asm"
.include "generate_array.asm"

.text
    .global  main                               # Обозначаем entry point
    .type   main, @function                     
    .type   run_console, @function
    .type   run_files, @function   
    
    run_console:
        push rbp                                # Пролог
        mov rbp, rsp                            
        
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
    
        lea rdi, msg_input_size[rip]            # Передаем указатель на подсказку для ввода размера массива
        call printf@plt                         # Выводим подсказку о вводе размера массива

        lea rdi, format_input_qword[rip]        # Передаем форматирование числа (первый аргумент)
        mov rsi, rsp                            # Указатель на место в памяти, куда нужно записать число (второй аргумент)
        call scanf@plt                          # Вызываем scanf c указанными аргументами (вводим размер массива с консоли)

        mov rdi, qword ptr[rsp]                 # Кладем размер массива в rdi
        cmp rdi, 0                              # Сравниваем размер массива с нулем
        jle .run_console_failed                 # Если размер <= 0, то прыгаем в конец
        
        cmp rdi, 1000000                        # Сравниваем размер массива с 1 миллионом
        jg .run_console_failed                  # Если размер строго больше, то завершаем программу (запрещены числа больше миллиона)

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
        jmp .run_console_final
        
        .run_console_failed:
        lea rdi, console_failed[rip]            # Передаем указатель на сообщение об ошибке
        call printf@plt                         # Выводим ошибку
        
        .run_console_final:
        
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        leave 
        ret
            
    run_files:
        push rbp                                # Пролог
        mov rbp, rsp
        
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        
        mov r12, rsi                            # Сохраняем указатель на массив для вывода
        
        call read_array_from_file               # Читаем массив из файла
        cmp rax, 0                              # Сравниваем указатель с nullptr
        je .read_failed                         # Если указатель nullptr, то чтение не удалось, а значит прыгаем на конечную метку заранее
        
        mov rbx, rax                            # Сохраняем указатель на прочитанный массив
        
        mov rdi, rax                            # Кладем указатель на прочитанный массив (первый аргумент)
        mov rsi, rdx                            # Кладем размер массива (второй аргумент)
        call transform_array                    # Трансформируем массив
        
        mov rdi, rax                            # Кладем указатель на массив (первый аргумент)
        mov rdx, r12                            # Кладем указатель на имя файла вывода (третий аргумент)
        call write_array_to_file                # Выводим размер массива и массив в файл
        
        call free@plt                           # Удаляем трансформированный массив
        
        mov rdi, rbx                            # Кладем указатель на прочитанный массив в rdi (первый аргумент)
        call free@plt                           # Удаляем прочитанный массив
        jmp .run_files_final
       
        .read_failed:                           
        lea rdi, file_failed_reading[rip]       # Сообщение о неудачном чтении массива с консоли
        xor eax, eax                            # Нулим rax
        call printf@plt                         # Выводим сообщение в консоль
        
        .run_files_final:
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        
        leave
        ret
        
    run_random_generated:
        push rbp                                # Пролог
        mov rbp, rsp
                
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        
        call generate_array                     # Генерируем массив с заданным размером
        mov rbx, rax                            # Сохраняем указатель на сгенерированный массив в rbx
        mov r12, rdx                            # Сохраняем размер сгенерированного массива в r13
        
        cmp rax, 0                              # Сравниваем указатель с nullptr
        je .generate_failed                     # Если указатель равен nullptr, то сгенерировать массив не удалось, прыгаем на метку для вывода ошибки в консоль
        
        mov rdi, rbx                            # Перемещаем указатель на массив в rdi (первый аргумент)
        mov rsi, r12                            # Перемещаем размер массива в rsi (второй аргумент)
        call transform_array                    # Вызываем трансформацию массива 
        mov rbx, rax                            # Сохраняем новый указатель в rbx (старый будет сохранен в rdi, благодаря нашим вызовам)
        
        lea rdx, generated_file_name[rip]       # Кладем указатель на строку с названием файла для вывода исходного массива в rdx (третий аргумент)
        call write_array_to_file                # Записываем сгенерированный массив в файл
        call free@plt                           # Удаляем сгенерированный массив (после запись в файл rdi все еще содержит валидный указатель)
        
        mov rdi, rbx                            # Кладем указатель на трансформированный массив в rdi (первый аргумент)
        mov rsi, r12                            # Кладем размер в rsi (второй аргумент)
        lea rdx, generated_transformed_file_name[rip]   # Кладем указатель на строку с названием файла для вывода трансформированного массива в rdx (третий аргумент)
        call write_array_to_file                # Записываем трансформированный массив в файл
        call free@plt                           # Удаляем трансформированный массив
        
        jmp .run_random_generated_final         # Пропускаем метку с выводом ошибки
        
        .generate_failed:
        lea rdi, generated_failed[rip]          # Сообщение о неудачном чтении массива с консоли
        xor eax, eax                            # Нулим rax
        call printf@plt                         # Выводим сообщение в консоль
        
        .run_random_generated_final:
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
        je .generate_all_mode                   # Если равно, то прыгаем на метку где происходит генерация массива вместе с размером
        
        cmp r12d, 3                             # Проверяем равно ли число аргументов 3 (-g value)
        je .generate_by_size_mode               # Если равно, то прыгаем на метку где происходит генерация массив по заданному размеру
        
        cmp r12d, 4                             # Проверяем равно ли число аргументов 4 (-f input_file.txt output_file.txt)
        je .file_mode                           # Если равно, то прыгаем на метку где происходит вызов функции, работающей с файлами
        
        .console_mode:
        call run_console                        # Ввод массива с консоли, преобразование, вывод в консоль
        jmp .main_final                         # Прыжок в конец функции
            
        .file_mode:
        mov rdi, [r13 + 16]                     # Кладем в rdi указатель на строку с именем входного файла (первый аргумент)
        mov rsi, [r13 + 24]                     # Кладем в rsi указатель на строку с именем выходного файла (второй аргумент)
        call run_files                          # Ввод массива из файла, преобразование, вывод в файл
        jmp .main_final
        
        .generate_all_mode:
        xor edi, edi                            # Нулим rdi как показатель того, что размер массива тоже нужно сгенерировать
        call run_random_generated               # Генерация массива, трансформация и вывод
        jmp .main_final
        
        .generate_by_size_mode:
        mov rdi, [r13 + 16]                     # Передаем указатель на строку которую нужно преобразовать
        lea rsi, format_input_qword[rip]        # Кладем указатель на форматирование числа (второй аргумент)
        lea rdx, qword ptr[rbp - 16]            # Передаем указатель на то, куда хотим записать число
        xor eax, eax                            # Нулим rax
        call sscanf@plt                         # Парсим строку в число
            
        mov rdi, qword ptr[rbp - 16]            # Кладем полученное число в rdi
        call run_random_generated               # Генерация массива по заданному размеру, трансформация и вывод

        .main_final:  
        
        add rsp, 16
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        
        xor eax, eax                            # Нулим rax как показатель корректного завершения работы программы
        leave
        ret