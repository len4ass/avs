.text
    .type   integrate, @function
        
    integrate:
        push rbp                                # Пролог
        mov rbp, rsp                                                          
        
        subsd xmm3, xmm2                        # Вычитаем из верхней границы нижнюю (получаем длину отрезка)
        cvttsd2si edx, xmm3                     # Кладем в edx целую часть от длины отрезка
        imul edx, 1000                          # Умножаем на 1000 (здесь будет кол-во разбиений)
        
        pxor xmm4, xmm4                         # Обнуляем xmm4
        cvtsi2sd xmm4, edx                      # Кладем кол-во разбиений в xmm4 (конвертация из int в double) 
        
        divsd xmm3, xmm4                        # Делим длину отрезка на кол-во разбиений
        cmp edx, 0                              # Сравниваем кол-во разбиений с нулем
        je .div_by_zero                         # Если равно 0, то прыгаем на метку div_by_zero
        
        xor eax, eax
        pxor xmm7, xmm7                         # Обнуляем xmm7
        mov rax, 4607182418800017408
        movq xmm6, rax                          # 1 в double representation
        mov rax, 4618441417868443648
        movq xmm8, rax                          # 6 в double representation
        mov rax, 4616189618054758400
        movq xmm9, rax                          # 4 в double representation
        mov rax, 4602678819172646912
        movq xmm10, rax                         # 0.5 в double representation
        xor eax, eax
        
        .integrate_loop:
            pxor xmm11, xmm11                   # Обнуляем xmm11
            cvtsi2sd xmm11, eax                 # Кладем текущую переменную цикла в xmm11
            mulsd xmm11, xmm3                   # Умножаем xmm11 на шаг
            addsd xmm11, xmm2                   # Прибавляем к xmm11 нижнюю границу интегрирования
            
            add eax, 1                          # Увеличиваем переменную цикла на 1
            pxor xmm5, xmm5                     # Обнуляем xmm5
            cvtsi2sd xmm5, eax                  # Кладем переменную цикла + 1 в xmm5
            mulsd xmm5, xmm3                    # Умножаем xmm5 на шаг
            addsd xmm5, xmm2                    # Прибавляем к xmm5 нижнюю границу интегрирования
            
            movapd xmm4, xmm11                  # Кладем xmm11 в xmm4 
            addsd xmm4, xmm5                    # Складываем x_i и x_i+1
            mulsd xmm4, xmm10                   # Умножаем (x_i + x_i+1) на 0.5
            mulsd xmm4, xmm4                    # Возводим в квадрат
            movapd xmm13, xmm6                  # Кладем 1 в xmm13
            divsd xmm13, xmm4                   # Делим 1 на (x_i + x_i+1)^2
            
            movapd xmm4, xmm13                  # Кладем результат в xmm4
            mulsd xmm4, xmm1                    # Умножаем (1 / (x_i + x_i+1)^2) на b
            addsd xmm4, xmm0                    # Прибавляем а к b / (x_i + x_i+1)^2
            mulsd xmm4, xmm9                    # Умножаем результат функции на 4    
            
            movapd xmm12, xmm11                 # Кладем xmm11 в xmm12 (x_i)
            mulsd xmm12, xmm11                  # Возводим x_i в квадрат
            movapd xmm14, xmm6                  # Кладем 1 в xmm14
            divsd xmm14, xmm12                  # Делим 1 на x_i^2
            movapd xmm12, xmm14                 # Кладем результат в xmm12
            mulsd xmm12, xmm1                   # Умножаем 1/x_i^2 на b
            addsd xmm12, xmm0                   # Прибавляем а к b/x_i^2
            addsd xmm4, xmm12                   # Прибавляем f(a, b, x) к 4f(a, b, (x_i + x_i+1))  
            
            movapd xmm12, xmm5                  # Кладем x_i+1 в xmm12
            mulsd xmm12, xmm5                   # Возводим x_i+1 в квадрат
            movapd xmm15, xmm6                  # Кладем 1 в xmm15
            divsd xmm15, xmm12                  # Делим 1 на x_i+1^2
            movapd xmm12, xmm15                 # Кладем 1/x_i+1^2 в xmm12
            mulsd xmm12, xmm1                   # Умножаем 1/x_i+1^2 на b
            addsd xmm12, xmm0                   # Прибавляем а к b/x_i+1^2
            addsd xmm4, xmm12                   # Прибавляем результат вычисления f(a, b, x_i+1) к внутренней скобке
            subsd xmm5, xmm11                   # Вычитаем х_i из x_i+1
            divsd xmm5, xmm8                    # Делим x_i - x_i+1 на 6
            
            mulsd xmm4, xmm5                    # Умножаем скобку на (x_i - x_i+1) / 6
            addsd xmm7, xmm4                    # Прибавляем результат на текущей итерации к общему результату
            
            cmp eax, edx                        # Сравниваем переменную цикла с количеством разбиений
            jnz .integrate_loop                 
                  
        
        movapd xmm0, xmm7                       # Кладем результат в xmm0
        jmp .end_integrate                      # Прыгаем на конец функции
        
        .div_by_zero:
        pxor xmm0, xmm0                         # Обнуляем результат
        
        .end_integrate:
        
        leave
        ret
    
