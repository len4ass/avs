.text
    .type   read_array_from_file, @function
    .type   write_array_to_file, @function

    read_array_from_file:
        push rbp                                # Пролог
        mov rbp, rsp
        push rdi                                # Сохраняем rdi на стэк для оптимизации вызовов
        push rsi                                # Сохраняем rsi на стэк для оптимизации вызовов
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)
        push r14                                # Сохраняем r14 на стэк (callee-saved register)
        sub rsp, 16                             # Память под локальную переменную + выравнивание стэка

        lea rsi, file_read[rip]                 # Передаем указатель на аргумент (доступ с чтением)
        call fopen@plt                          # Открываем поток к файлу
        
        mov r12, rax                            # Сохраняем указатель на поток к файлу

        mov rdi, rax                            # Указатель на поток к файлу (первый аргумент)
        lea rsi, format_input_qword[rip]        # Форматирование числа (второй аргумент)
        lea rdx, qword ptr[rsp - 16]            # Указатель на память, куда положим размер (третий аргумент)
        xor eax, eax                            # Указываем, что функция принимает определенное кол-во аргументов
        call fscanf@plt                         # Читаем размер массива из файла
        
        mov rdi, qword ptr[rsp - 16]            # Кладем в rdi размер массива
        cmp rdi, 0                              # Сравниваем размер с 0
        jle .set_ptr_null                       # Если размер <= 0, то прыгаем на метку set_ptr_null
        
        cmp rdi, 1000000                        # Сравниваем размер с 1 миллионом
        jg .set_ptr_null                        # Если размер строго больше, то прыгаем на метку set_ptr_null
        
        mov r14, rdi                            # Сохраняем размер в r14
        sal rdi, 3                              # Умножаем переданный размер на 8 битовым сдвигом влево
        call malloc@plt                         # Выделяем память через malloc
        mov rbx, rax                            # Сохраняем указатель на выделенную память в rbx
        
        xor r13d, r13d                          # Зануляем переменную цикла
        .loop_file_read_array:
            cmp r13, r14                        # Сравнение переменной цикла с размером
            jge .read_file_final                # Если переменная цикла >= размера, то прыгаем на конец цикла
            
            mov rdi, r12                                    # Указатель на поток к файлу (первый аргумент)
            lea rsi, format_file_input_element[rip]         # Форматирование числа (второй аргумент)
            lea rdx, qword ptr[rbx + 8 * r13]               # Указатель на память, куда положим размер (третий аргумент)
            xor eax, eax                        # Указываем, что функция принимает определенное кол-во аргументов
            call fscanf@plt                     # Читаем число из файла
            
            cmp rax, -1                         # Сравниваем, пришли ли к EOF
            je .read_file_final                 # Досрочно заканчиваем чтение из файла, если EOF
            
            inc r13                             # Увеличиваем переменную цикла
            jmp .loop_file_read_array           # Возвращаемся к началу цикла
        
        .set_ptr_null: 
        mov rdi, r12                            # Указатель на поток к файлу (первый аргумент)
        call fclose@plt                         # Закрываем поток к файлу
        
        xor eax, eax                            # Нулим rax как показатель того, что указатель nullptr, следовательно чтение не удалось
        jmp .read_file_end                      # Прыгаем на метку read_file_end
        
        .read_file_final:  
        mov rdi, r12                            # Указатель на поток к файлу (первый аргумент)
        call fclose@plt                         # Закрываем поток к файлу
        
        mov rax, rbx                            # Возвращаем указатель на заполненный массив
        mov rdx, r14                            # Возвращаем размер массива
        
        .read_file_end:
        
        add rsp, 16                             # Чистим память и убираем выравнивание
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rsi                                 # Восстанавливаем rsi к изначальному состоянию
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию
    
        leave
        ret
        
    write_array_to_file:
        push rbp                                # Пролог
        mov rbp, rsp    
        
        push rdi                                # Сохраняем rdi на стэк для оптимизации вызовов
        push rsi                                # Сохраняем rsi на стэк для оптимизации вызовов
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)
        push r14                                # Сохраняем r14 на стэк (callee-saved register)

        mov rbx, rdi                            # Сохраняем указатель на массив в rbx
        mov r14, rsi                            # Сохраняем размер массива в r14
   
        mov rdi, rdx
        lea rsi, file_write[rip]                # Передаем указатель на аргумент (доступ с записью)
        xor eax, eax                            # Указываем, что нет чисел с плавающей точкой
        call fopen@plt                          # Открываем поток к файлу
        
        mov r12, rax                            # Сохраняем указатель на поток к файлу в r12
        
        mov rdi, r12                            # Указатель на поток к файлу (первый аргумент)
        lea rsi, format_input_qword[rip]        # Формат вывода (второй аргумент)
        mov rdx, r14                            # Размер массива (третий аргумент)
        xor eax, eax                            # Указываем, что функция принимает определенное кол-во аргументов
        call fprintf@plt
        
        xor r13d, r13d                          # Переменная цикла
        .loop_write_to_file_start:
            cmp r13, r14                        # Сравнение переменной цикла с размером
            jge .loop_write_to_file_end         # Если переменная цикла >= размера, то прыгаем на конец цикла
            
            mov rdi, r12                            # Указатель на поток к файлу (первый аргумент)
            lea rsi, format_file_input_element[rip] # Указатель на форматирование вывода (второй аргумент)
            mov rdx, qword ptr[rbx + 8 * r13]       # Текущий элемент (третий аргумент)
            xor eax, eax                        # Указываем, что функция принимает определенное кол-во аргументов
            call fprintf@plt                    # Выводим число в файл
            
            inc r13                             # Увеличиваем переменную цикла
            jmp .loop_write_to_file_start       # Прыгаем на начало цикла
        .loop_write_to_file_end:
        xor eax, eax
        mov rdi, r12                            # Указатель на поток к файлу (первый аргумент)
        call fclose@plt                         # Закрываем поток к файлу
        
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        pop rsi                                 # Восстанавливаем rsi к изначальному состоянию
        pop rdi                                 # Восстанавливаем rdi к изначальному состоянию
        
        leave                                   # Эпилог
        ret                                         
