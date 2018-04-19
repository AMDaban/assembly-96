;_quick_sort sorts parameter 1(target array) from parameter 2(start index) to parameter 3(end index)

section .data
    ;array to sort
    source dw 10, -1, 9, -2, 8, -3, 7, -4, 6, -5, 5, -6, 4, -7, 3, -8, 2, -9, 1, -10, 1, 1, -1, -1

    ;array length 
    len equ ($ - source)/2

section .text
    global _start                                          

_start:
    mov ax, len
    dec ax
    push ax                             ;set third parameter(end)

    mov ax, 0
    push ax                             ;set second parameter(start)

    mov rax, source                     
    push rax                            ;set first parameter(array pointer)

    call _quick_sort                    

    mov rcx, len
    mov r8, source
    check_loop:
    mov bx, [r8]
check:
    inc r8
    inc r8
    loop check_loop
    
exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_quick_sort:                            ;_quick_sort sorts parameter 1(target array) from parameter 2(start index) to parameter 3(end index) 

    enter 12, 0                         ;reserve space for local variables

    mov r8w, [rbp + 24]
    mov [rbp - 2], r8w                  ;[rbp - 2] -> start (16 bit)

    mov r8w, [rbp + 26]
    mov [rbp - 4], r8w                  ;[rbp - 4] -> end (16 bit)

    mov r8, [rbp + 16]
    mov [rbp - 12], r8                  ;[rbp - 12] -> array (64 bit)
    
    mov r8w, [rbp - 4]                  ;base case
    mov r9w, [rbp - 2]
    cmp r8w, r9w
    jg size_greater_than_zero
        leave
        ret 12
    size_greater_than_zero:

    mov ax, [rbp - 4]
    push ax                             ;set third parameter(end)

    mov ax, [rbp - 2]
    push ax                             ;set second parameter(start)

    mov rax, [rbp - 12]                     
    push rax                            ;set first parameter(array pointer)
 
    call _partition

    dec ax

    push ax

    push ax                             ;set third parameter(end)

    mov bx, [rbp - 2]
    push bx                             ;set second parameter(start)

    mov rbx, [rbp - 12]                     
    push rbx                            ;set first parameter(array pointer)

    call _quick_sort

    pop ax

    add ax, 2

    mov bx, [rbp - 4]
    push bx                             ;set third parameter(end)

    push ax                             ;set second parameter(start)

    mov rbx, [rbp - 12]                     
    push rbx                            ;set first parameter(array pointer)

    call _quick_sort

    leave

    ret 12

;---------------------------------------

_partition:

    enter 12, 0                         ;reserve space for local variables

    mov r8w, [rbp + 24]
    mov [rbp - 2], r8w                  ;[rbp - 2] -> start (16 bit)

    mov r8w, [rbp + 26]
    mov [rbp - 4], r8w                  ;[rbp - 4] -> end (16 bit)

    mov r8, [rbp + 16]
    mov [rbp - 12], r8                  ;[rbp - 12] -> array (64 bit)

    xor r8, r8                          ;load last index in ax
    add r8w, [rbp - 4]
    add r8w, [rbp - 4]
    add r8, [rbp - 12]
    mov r8w, [r8]                       ;pivot 

    xor r9, r9
    mov r9w, [rbp - 2]
    dec r9w                             ;index of smaller element

    xor r10, r10
    mov r10w, [rbp - 2]                 ;start
    
    xor r11, r11
    mov r11w, [rbp - 4]                 ;end - 1
    dec r11w

    partition_main_loop:

        cmp r10w, r11w
        jg partition_out_of_loop

        mov r12, [rbp - 12]
        add r12, r10
        add r12, r10
        mov ax, [r12] 

        cmp ax, r8w
        jg not_greater
            inc r9w                     ;increment index of smaller element
            
            mov r13, [rbp - 12]
            add r13, r9
            add r13, r9

            mov bx, [r13]               ;swap [r13, r12]                       
            mov cx, [r12]
            mov [r13], cx
            mov [r12], bx

        not_greater:

        inc r10w

    jmp partition_main_loop

    partition_out_of_loop:

    inc r9w
    
    mov r14, [rbp - 12]
    add r14, r9
    add r14, r9

    mov r15, [rbp - 12]
    inc r11w
    add r15, r11
    add r15, r11
    
    mov ax, [r15]
    mov bx, [r14]
    mov [r15], bx
    mov [r14], ax

    mov ax, r9w

    leave

    ret 12

;---------------------------------------
