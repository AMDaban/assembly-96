;_binary_search searches for parameter 4(key) in parameter 1(array) from start(parameter 2) to end(parameter 3)

section .data
    ;array to search in
    source dw -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

    ;array length 
    len equ ($ - source)/2

    ;key to search
    search_key dw -2    

section .text
    global _start                                          
_start:
    push word [search_key]              ;set fourth parameter(key)

    mov ax, len
    dec ax
    push ax                             ;set third parameter(end)

    push word 0                         ;set second parameter(start)

    push qword source                   ;set first parameter(array pointer) 

    call _binary_search             
    
exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_binary_search:                         ;_binary_search searches for parameter 4(key) in parameter 1(array) from start(parameter 2) to end(parameter 3)

    enter 14, 0

    mov r8w, [rbp + 24]
    mov [rbp - 2], r8w                  ;[rbp - 2] -> start (16 bit)

    mov r8w, [rbp + 26]
    mov [rbp - 4], r8w                  ;[rbp - 4] -> end (16 bit)

    mov r8w, [rbp + 28]
    mov [rbp - 6], r8w                  ;[rbp - 6] -> key (16 bit)

    mov r8, [rbp + 16]
    mov [rbp - 14], r8                  ;[rbp - 14] -> array (64 bit)

    mov r8w, [rbp - 4]                  ;check if start <= end
    mov r9w, [rbp - 2]
    cmp r8w, r9w
    jge end_not_less_than_start
        mov ax, -1
        leave    
        ret 14
    end_not_less_than_start:

    xor r8, r8                          ;compute index of the middle number 
    mov r8w, [rbp - 4]
    sub r8w, [rbp - 2]
    sar r8, 1
    xor r9, r9
    mov r9w, [rbp - 2]
    add r8, r9 

    mov r9, [rbp - 14]                  ;retrieve value of the middle number 
    add r9, r8
    add r9, r8
    mov r10w, [r9]

    mov r9w, [rbp - 6]
    cmp r9w, r10w
    jne not_equal
        mov ax, r8w
        leave    
        ret 14
    not_equal:

    cmp r9w, r10w
    jnl not_lower
        push word [rbp - 6]                 ;set fourth parameter(key)

        mov ax, r8w
        dec ax
        push ax                             ;set third parameter(end)

        push word [rbp - 2]                 ;set second parameter(start)

        push qword [rbp - 14]               ;set first parameter(array pointer) 

        call _binary_search

        leave    
        ret 14
    
    not_lower:

    push word [rbp - 6]                     ;set fourth parameter(key)

    push word [rbp - 4]                     ;set third parameter(end)

    mov ax, r8w
    inc ax
    push ax                                 ;set second parameter(start)                 

    push qword [rbp - 14]                   ;set first parameter(array pointer) 

    call _binary_search

    leave    
    ret 14

;---------------------------------------
