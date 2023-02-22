.text
    .type   generate_array, @function
    
    generate_array:
        push rbp                                # Пролог
        mov rbp, rsp                            
  
        push rbx                                # Сохраняем rbx на стэк (callee-saved register)
        push r12                                # Сохраняем r12 на стэк (callee-saved register)
        push r13                                # Сохраняем r13 на стэк (callee-saved register)
        sub rsp, 8                              # Выравнивание стэка
        mov r13, rdi                            # Сохраняем размер генерируемого массива в r13
        
        xor rdi, rdi                            # Нулим rdi, иначе time попытается положить результат вызова еще и туда
        call time@plt                           # Получаем unix_time в rax
        mov rdi, rax                            # Кладем unix_time в rdi (устанавливаем seed генератора)
        call srandom@plt                        # Ставим seed для последующих вызовов random
        
        cmp r13, 0                              # Сравниваем переданный размер с нулем
        jl .set_null_ptr                        # Если < 0, то размер некорректен, прыгаем на метку .set_null_ptr
        
        cmp r13, 1000000                        # Сравниваем переданный размер с 1 миллионом
        jg .set_null_ptr                        # Если строго больше, то прыгаем на метку .set_null_ptr
        
        cmp r13, 0                              # Сравниваем переданный размер с нулем
        jne .generate_skip_sz_random            # Если != 0, то размер корректен и его не нужно генерировать
        
        call random@plt                         # Генерируем случайное число (результат в rax)
        mov r13, rax                            # Сохраняем случайное число в r13
        
        .generate_skip_sz_random:
        mov rax, r13                            # Перемещаем в rax делимое
        xor edx, edx                            # Нулим остаток
        mov rcx, 1000001                        # Указываем число, на которое делим
        div rcx                                 # Беззнаково делим случайное число на 1000001 
        mov r13, rdx                            # Сохраняем остаток
        
        cmp r13, 0                              # Сравниваем остаток с нулем
        jne .generate_array_alloc               # Если остаток не равен нулю, то прыгаем сразу к аллокации
        inc r13                                 # Увеличиваем остаток от деления (размер) на 1, чтобы он был в рамках [1, 10000]
        
        .generate_array_alloc:
        mov rdi, r13                            # Перемещаем размер в rdi
        sal rdi, 3                              # Умножаем переданный размер на 8 битовым сдвигом влево
        call malloc@plt                         # Выделяем память через malloc
        mov rbx, rax                            # Сохраняем указатель на выделенную память в rbx

        xor r12d, r12d                          # Зануляем переменную цикла
        .loop_generate_array_start:
            cmp r12, r13                        # Сравнение переменной цикла с размером
            jge .generate_end                   # Если переменная цикла >= размера, то прыгаем на конец функции
            
            call random@plt                     # Генерируем число
            mov qword ptr[rbx + 8 * r12], rax   # Помещаем сгенерированное число на место переменной цикла в массиве

            inc r12                             # Увеличиваем переменную цикла
            jmp .loop_generate_array_start      # Прыгаем на начало цикла      
        
        .set_null_ptr:
        xor ebx, ebx                            # Обнуляем указатель на массив как показатель того, что функция завершилась некорректно 
        xor r12d, r12d                          # Обнуляем размер
            
        .generate_end:
        mov rax, rbx                            # Возвращаем указатель на сгенерированный массив в rax
        mov rdx, r12                            # Возвращаем размер массива в rdx
        
        add rsp, 8                              # Убираем выравнивание
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        
        leave                                   # Эпилог
        ret
        