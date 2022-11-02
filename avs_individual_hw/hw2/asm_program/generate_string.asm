.text
    .type   generate_string, @function
    
    generate_string:
        push rbp                                # Пролог
        mov rbp, rsp
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        push r13                                # Сохраняем r13 (callee-saved register)
        push r14                                # Сохраняем r14 (callee-saved register)
        push r15                                # Сохраняем r15 (callee-saved register)
        sub rsp, 8
        
        mov rbx, rdi                            # Кладем размер строки в rbx
        mov r12, rsi                            # Кладем размер строки в r12
        
        xor rdi, rdi                            # Нулим rdi, иначе time попытается положить результат вызова еще и туда
        call time@plt                           # Получаем unix_time в rax
        mov rdi, rax                            # Кладем unix_time в rdi (устанавливаем seed генератора)
        call srandom@plt                        # Ставим seed для последующих вызовов random
        
        cmp rbx, 0                              # Сравниваем размер строки с 0
        jne .skip_size_gen                      # Если не равен 0, то пропускаем генерацию размера (прыжок на метку skip_size_gen)
        
        call random@plt                         # Генерируем размер
        mov rbx, rax                            # Сохраняем размер в rbx
        
        .skip_size_gen:
        mov rax, rbx                            # Перемещаем в rax делимое
        xor edx, edx                            # Нулим остаток
        mov rcx, 1000001                        # Указываем число, на которое делим
        div rcx                                 # Беззнаково делим случайное число на 1000001 
        mov rbx, rdx                            # Сохраняем остаток
        
        cmp r12, 0                              # Сравниваем длину последовательности с 0
        jne .skip_len_gen                       # Если не равна 0, то пропускаем генерацию длины (прыжок на метку skip_len_gen)
        
        call random@plt                         # Генерируем длину
        mov r12, rax                            # Сохраняем длину в r12
        
        .skip_len_gen:
        mov rax, r12                            # Перемещаем в rax делимое
        xor edx, edx                            # Нулим остаток
        mov rcx, 101                            # Указываем число, на которое делим
        div rcx                                 # Беззнаково делим случайное число на 1000001 
        mov r12, rdx                            # Сохраняем остаток
        
        mov rdi, rbx                            # Кладем размер в rdi
        inc rdi                                 # Увеличиваем размер на 1 (чтобы последним символом был NULL)
        call malloc@plt                         # Выделяем память под null-terminated строку
        mov r13, rax                            # Сохраняем указатель в r13
        
        xor r15d, r15d                          # Обнуляем переменную цикла
        .start_loop_gen:
            cmp r15, rbx                        # Сравниваем переменную цикла с размером
            jge .end_loop_gen                   # Если >= 0, то выпрыгиваем из цикла
            
            call random@plt                     # Генерируем число
            mov rdi, rax                        # Кладем число в rdi
            call abs@plt                        # Берем число по модулю
            xor edx, edx                        # Нулим остаток
            mov rcx, 95                         # Указываем число, на которое делим
            div rcx                             # Беззнаково делим случайное число на 95
            mov r14, rdx                        # Сохраняем остаток
            add r14, 32                         # Добавляем 32, теперь наш символ в диапазоне [32, 126]
            
            mov byte ptr[r13 + r15], r14b       # Кладем текущий символ на r15 место в строке
            inc r15                             # Увеличиваем переменную цикла
            jmp .start_loop_gen                 # Прыгаем на начало цикла
        .end_loop_gen:
        
        mov byte ptr[r13 + rbx], 0              # Ставим NULL в конец строки, чтобы указать, что она null-terminated
        mov rax, r13                            # Возвращаем указатель на строку в rax
        mov rdx, rbx                            # Возвращаем размер строки в rdx
        mov rcx, r12                            # Возвращаем длину последовательности в rcx
        
        add rsp, 8                  
        pop r15                                 # Восстанавливаем r15 к изначальному состоянию
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        
        leave
        ret
