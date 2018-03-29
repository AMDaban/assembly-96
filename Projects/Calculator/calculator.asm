section .data
    msg dq 0                    ;string address which will be written
    msglen dq 0                 ;string length which will be written

    first_message db 'Simple Calculator: (write a simple expression)', 10
    first_message_len equ $ - first_message

section .bss
    input resb 100              ;stores user input

section .text
    global _start                                          
_start:

    mov rax, first_message      ;print first_message
    mov [msg], rax
    mov rax, first_message_len
    mov [msglen], rax
    call _print_string

    call _get_user_input        ;get first user input

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;-------------------------------

_print_string:                  ;simply print the string with length msglen that its address stored in msg
    
    mov eax, 4                  ;'write' system call
    mov ebx, 1                  ;file descriptor 1 = screen
    mov ecx, [msg]              ;string to write       
    mov edx, [msglen]           ;length of string to write
 
    int 80h                     ;call the kernel
    
    ret

;-------------------------------

_get_user_input:                ;simply get user input and store it in the input array(max length = 100 character)

    mov rax, 0                  ;'read' system call
    mov rdi, 0                  ;standard input
    mov rsi, input              ;input will be in input array 
    mov rdx, 100                ;max length of input
    
    syscall                     ;call the kernel

    ret

;-------------------------------

_clear_array:

    mov rcx, 100
    mov esi, input
    clearloop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearloop

    ret
;-------------------------------