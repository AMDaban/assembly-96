section .data
    ;array to sort
    source dw 990, 100, 8, 7, 103, 5, -20000, -3, 2, 876

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
exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_quick_sort:                            ;_quick_sort sorts an array witch rax points to.(with length bx) 

    enter 12, 0                         ;reserve space for local variables

    mov r8w, [rbp + 24]
    mov [rbp - 2], r8w                  ;[rbp - 2] -> start (16 bit)

    mov r8w, [rbp + 26]
    mov [rbp - 4], r8w                  ;[rbp - 4] -> end (16 bit)

    mov r8, [rbp + 16]
    mov [rbp - 12], r8                  ;[rbp - 12] -> array (64 bit)

    
    mov r8w, [rbp - 4]                  ;base case(if end >=)
    mov r9w, [rbp - 2]
    cmp r8w, r9w
    jg size_greater_than_zero
        leave
        ret
    size_greater_than_zero:

    mov ax, [rbp - 4]
    push ax                             ;set third parameter(end)

    mov ax, [rbp - 2]
    push ax                             ;set second parameter(start)

    mov rax, [rbp - 12]                     
    push rax                            ;set first parameter(array pointer)
 
    call _partition

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
    mov ax, [r8]

    

    leave

    ret 12

;---------------------------------------
