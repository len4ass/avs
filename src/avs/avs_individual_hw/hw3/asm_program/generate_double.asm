.text
    .type   generate_double, @function
    
    generate_double:
        push rbp                                # Пролог
        mov rbp, rsp  
        sub rsp, 16
        
        movsd qword ptr[rbp - 16], xmm0         # Сохраняем левую границу генерации
        movsd qword ptr[rbp - 8], xmm1          # Сохраняем правую границу генерации
        
        call rand@plt                           # Генерируем случайное число
        
        pxor xmm0, xmm0                         # Обнуляем xmm0
        cvtsi2sd xmm0, eax                      # Конвертируем случайное число в double
        
        movsd xmm2, qword ptr[rbp - 8]          # Кладем в xmm2 правую границу
        movsd xmm3, qword ptr[rbp - 16]         # Кладем в xmm3 левую границу
        
        subsd xmm2, xmm3                        # Вычитаем из правой границы левую
        mov rax, 4746794007244308480
        movq xmm1, rax                          # Кладем в xmm1 максимальное число в double repr
        divsd xmm1, xmm2                        # Делим максимальное число на разность
        divsd xmm0, xmm1                        # Делим случайное число на частное
        addsd xmm0, xmm3                        # Прибавляем к левой границе результат из xmm0                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        add rsp, 16
        leave
        ret
