.text
    .type   check_sequence, @function
    .type   find_sequence, @function
    
    check_sequence:
        push rbp                                # Пролог
        mov rbp, rsp                                                          
        xor ecx, ecx                            # Обнуляем переменную цикла
        
        .start_check_loop:
            mov al, byte ptr[rdi + rcx]         # Текущий char кладем в al
            mov dl, byte ptr[rdi + rcx + 1]     # Следующий char кладем в dl
            
            cmp dl, 0                           # Проверяем dl на равенство 0
            je .check_sequence_final            # Если равно прыгаем на конец
            
            cmp dl, al                          # Сравниваем dl и al
            jge .sequence_invalid               # Если dl >= al, то последовательность невалидна => прыгаем на sequence_invalid
            
            inc rcx                             # Увеличиваем переменную цикла
            jmp .start_check_loop               # Возвращаемся в самое начало
             
        .check_sequence_final:
        mov rax, 1                              # Кладем 1 в rax (valid sequence)
        jmp .check_sequence_end
       
        .sequence_invalid:
        xor eax, eax                            # Обнуляем rax (invalid sequence)
        
        .check_sequence_end:
       
        leave
        ret
    
    find_sequence:
        push rbp                                # Пролог
        mov rbp, rsp
        push rbx                                # Сохраняем rbx (callee-saved register)
        push r12                                # Сохраняем r12 (callee-saved register)
        push r13                                # Сохраняем r13 (callee-saved register)
        push r14                                # Сохраняем r14 (callee-saved register)
        push r15                                # Сохраняем r15 (callee-saved register)
        sub rsp, 8  
        
        mov rbx, rdi                            # Сохраняем указатель на строку в rbx
        mov r12, rsi                            # Сохраняем размер строки в r12
        mov r13, rdx                            # Сохраняем размер искомой последовательности в r13
        
        mov rdi, rdx                            # Кладем размер искомой последовательности в rdi
        inc rdi                                 # Увеличиваем на 1
        call malloc@plt                         # Выделяем память под последовательность и NULL байт
        mov r14, rax                            # Сохраняем указатель на последовательность в r14
        
        xor r15d, r15d                          # Обнуляем r15 (флаг, обозначающий, была ли найдена валидная последовательность)
        xor ecx, ecx                            # Обнуляем переменную цикла
        .start_find_loop:
            mov rdx, r12                        # Кладем в rdx размер строки
            sub rdx, r13                        # Вычитаем из rdx длину искомой последовательности
            inc rdx                             # Добавляем единицу
            cmp rcx, rdx                        # Сравниваем rcx с rdx (i ? size - sequence_len + 1)
            jge .end_find_loop                  # Если переменная цикла больше size - sequence_len + 1, то прыгаем на конец цикла
  
            mov rdi, r14                        # Кладем указатель на последовательность в rdi
            mov rsi, rbx                        # Кладем указатель на строку в rsi
            add rsi, rcx                        # Сдвигаем указатель на rcx байт
            mov rdx, r13                        # Кладем в rdx количество байт для копирования
            
            push rcx                            # Сохраняем rcx
            call memcpy@plt                     # Копируем подстроку в последовательность
                                                
            mov byte ptr[r14 + r13], 0          # Кладем NULL в конец последовательности
            
            mov rdi, r14                        # Кладем последовательность в rdi
            call check_sequence                 # Проверяем ее на валидность
            mov r15, rax                        # Сохраняем значение валидности в r15
            
            pop rcx                             # Восстанавливаем rcx
            cmp r15, 1                          # Сравниваем r15 с 1
            je .end_find_loop                   # Если равно 1, то последовательность найдена, выходим
            
            inc rcx                             # Увеличиваем переменную цикла на 1
            jmp .start_find_loop                # Прыгаем на начало цикла
        .end_find_loop:
        
        cmp r15, 0                              # Сравниваем флаг валидности с нулем
        jne .find_sequence_final                # Если не равен нулю, то прыгаем на find_sequence_finalk
        
        mov rdi, r14                            # Кладем указатель на последовательность в rdi
        call free@plt                           # Высвобождаем память
        xor r14d, r14d                          # Обнуляем r14, где лежит указатель на последовательность
        
        .find_sequence_final:
        mov rax, r14                            # Кладем указатель на последовательность в rax
        
        add rsp, 8
        pop r15                                 # Восстанавливаем r15 к изначальному состоянию
        pop r14                                 # Восстанавливаем r14 к изначальному состоянию
        pop r13                                 # Восстанавливаем r13 к изначальному состоянию
        pop r12                                 # Восстанавливаем r12 к изначальному состоянию
        pop rbx                                 # Восстанавливаем rbx к изначальному состоянию
        leave                                   # Эпилог
        ret
