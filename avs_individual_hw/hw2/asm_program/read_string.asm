.text
    .type   read_string, @function
    
    read_string:
        push rbp                                # Пролог
        mov rbp, rsp
        
        push rbx                                # Сохраняем callee-saved register - служит под поток ввода
        push r12                                # Сохраняем callee-saved register - служит под размер буфера (изменяемый)
        push r13                                # Сохраняем callee-saved register - служит под указатель на строку (буфер)
        push r14                                # Сохраняем callee-saved register - служит под переменную цикла
        push r15                                # Сохраняем callee-saved register - служит под временный буфер           
        sub rsp, 8
        
        mov rbx, rdi                            # Сохраняем указатель на поток ввода
        
        cmp rdi, 0                              # Сравниваем указатель на поток с 0 (NULL)
        jne .skip_stdin_setter                  # Если не NULL, то прыгаем на метку .skip_stdin_setter
        
        mov rbx, stdin[rip]                     # Ставим указатель потока вывода на stdin
        
        .skip_stdin_setter:
        mov r12, 1024                           # Устанавливаем стандартный размер буфера 
        
        mov rdi, r12                            # Перемещаем размер буфера в rdi
        call malloc@plt                         # Выделяем память под буфер
        
        mov r13, rax                            # Сохраняем указатель на буфер в r13
        xor r14d, r14d                          # Обнуляем переменную цикла
        .start_read_string_loop:
            mov rdi, rbx                        # Кладем в rdi указатель на поток ввода
            call getc@plt                       # Получаем char с потока
            
            mov byte ptr[rbp - 8], al           # Сохраняем char 
            
            cmp byte ptr[rbp - 8], 255          # Сравниваем char с 255 (EOF)
            je .end_read_string_loop            # Если char = EOF, то выходим из цикла (прыгаем на метку end_read_string_loop)
            
            cmp byte ptr[rbp - 8], 0            # Сравниваем char c 0 ('\0' = NULL)
            je .end_read_string_loop            # Если char = '\0', то выходим из цикла (прыгаем на метку end_read_string_loop)
            
            cmp byte ptr[rbp - 8], 10           # Сравниваем char с 10 ('\n')
            je .cmp_input_ptr                   # Если char = '\n', то прыгаем на метку cmp_input_ptr, где проверяем, чему равен указатель на поток ввода
            jmp .skip_cmp_input_ptr             # Иначе скипаем проверку
            
            .cmp_input_ptr:
            cmp rbx, stdin[rip]                 # Сравниваем указатель на поток ввода с stdin
            je .end_read_string_loop            # Если указатель на поток ввода равен stdin, то выходим из цикла (прыгаем на метку end_read_string_loop)
            
            .skip_cmp_input_ptr:
            mov al, byte ptr[rbp - 8]           # Кладем char в 8битный регистр перед тем, как положить в буфер
            mov byte ptr[r13 + r14], al         # Кладем в буфер на следующее место
            inc r14                             # Увеличиваем позицию буфера
            
            cmp r14, r12                        # Сравниваем позицию буфера с размером буфера
            je .resize_buf                      # Если позиция буфера равна размеру буферу, то увеличиваем размер буфера в 2 раза (прыгаем на метку resize_buf)
            
            jmp .start_read_string_loop              # Если прошлого прыжка не произошло, то переместимся в начало цикла
            
            .resize_buf:
            mov rdi, r12                        # Кладем текущий размер буфера в rdi
            shl rdi, 1                          # Побитовый сдвиг на 1 для умножения на два
            call malloc@plt                     # Выделяем новый буфер 
            mov r15, rax                        # Сохраняем временный буфер в r15
            
            mov rdi, r15                        # Кладем временный буфер (dest) в rdi
            mov rsi, r13                        # Кладем старый буфер (src) в rsi
            mov rdx, r12                        # Кладем размер буфера (size) в rdx
            call memcpy@plt                     # Производим копирование памяти в новый буфер
            
            mov rdi, r13                        # Перемещаем указатель на старый буфер в rdi
            call free@plt                       # Высвобождаем память от старого буфера
            
            mov r13, r15                        # Обновляем старый буфер на новый
            shl r12, 1                          # Увеличиваем размер текущего буфера в два раза побитовым сдвигом
            jmp .start_read_string_loop         # Прыгаем в начало цикла
        .end_read_string_loop:
        
        cmp r12, r14                            # Сравниваем сколько байт буфера заполнено по сравнению с размером
        jle .read_string_null_terminated        # Если заполнен весь буфер, то прыгаем на метку, где происходит превращение буфера в null-terminated string 
        
        mov rdi, r14                            # Кладем в rdi сколько байт буфера было заполнено
        inc rdi                                 # Увеличиваем это количество на 1 (чтобы затем последний байт заполнить NULL)
        call malloc@plt                         # Выделяем новый буфер
        mov r15, rax                            # Сохраняем временный буфер в r15
        
        mov rdi, r15                            # Кладем временный буфер (dest) в rdi
        mov rsi, r13                            # Кладем старый буфер (src) в rsi
        mov rdx, r14                            # Кладем размер буфера (size) в rdx
        call memcpy@plt                         # Производим копирование памяти в новый буфер
        
        mov rdi, r13                            # Перемещаем указатель на старый буфер в rdi
        call free@plt                           # Высвобождаем память от старого буфера
        
        mov r13, r15                            # Обновляем старый буфер на новый
        
        .read_string_null_terminated:
        mov byte ptr[r13 + r14], 0              # Заполняем последний байт буфера NULL        
        cmp r14, 0                              # Сравниваем реальный размер буфера с 0
        jne .read_string_final                  # Если реальный размер не равен 0, то прыгаем на конец функции, иначе высвобождаем память буфера и кладем в rax NULL
        
        mov rdi, r13                            # Кладем указатель на буфер в rdi
        call free@plt                           # Высвобождаем память
        xor r13d, r13d                          # Кладем вместо указателя на буфер NULL
        
        .read_string_final:
        mov rax, r13                            # Устанавливаем возвращаемое значение (считанную null-terminated строку)
        mov rdx, r14                            # Устанавливаем возвращаемое значение (размер строки)
        
        add rsp, 8
        pop r15                                 # Восстанавливаем изначальное значение r15
        pop r14                                 # Восстанавливаем изначальное значение r14
        pop r13                                 # Восстанавливаем изначальное значение r13
        pop r12                                 # Восстанавливаем изначальное значение r12
        pop rbx                                 # Восстанавливаем изначальное значение rbx
        
        leave
        ret