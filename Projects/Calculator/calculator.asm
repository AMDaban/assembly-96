section .data
    msg dq 0                    ;string address which will be written
    msglen dq 0                 ;string length which will be written

    first_message db 'Simple Calculator: (write a simple expression)', 10
    first_message_len equ $ - first_message

section .text
    global _start                                          
_start:

    mov rax, first_message      ;print first_message
    mov [msg], rax
    mov rax, first_message_len
    mov [msglen], rax
    call _print_string


exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;-------------------------------

_print_string:                  ;simply prints the string with length msglen that its address stored in msg
    
    mov eax, 4                  ;'write' system call
    mov ebx, 1                  ;file descriptor 1 = screen
    mov ecx, [msg]              ;string to write       
    mov edx, [msglen]           ;length of string to write
 
    int 80h                     ;call the kernel
    
    ret

;-------------------------------