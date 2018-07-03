section .data
    termios         times 36 db 0
    stdin           equ 0
    ICANON          equ 1 << 1
    ECHO            equ 1 << 3

    input_char      dd 0

section .text
    global _start                                          
_start:
    call canonical_off

exit:
    call canonical_on
    
    mov ebx, 0
    mov eax, 1
    int 80h
;--------------------------------
read_single_char:

    push rax
    push rdi
    push rsi
    push rdx

    mov rax, 0
	mov rdi, 0
	mov rsi, input_char
	mov rdx, 2
	syscall

    pop rdx
    pop rsi
    pop rdi
    pop rax

    ret
;--------------------------------

canonical_off:
        call read_stdin_termios

        ; clear canonical bit in local mode flags
        push rax
        mov eax, ICANON
        not eax
        and [termios+12], eax
        pop rax

        call write_stdin_termios
        ret

echo_off:
        call read_stdin_termios

        ; clear echo bit in local mode flags
        push rax
        mov eax, ECHO
        not eax
        and [termios+12], eax
        pop rax

        call write_stdin_termios
        ret

canonical_on:
        call read_stdin_termios

        ; set canonical bit in local mode flags
        or dword [termios+12], ICANON

        call write_stdin_termios
        ret

echo_on:
        call read_stdin_termios

        ; set echo bit in local mode flags
        or dword [termios+12], ECHO

        call write_stdin_termios
        ret

read_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5401h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

write_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5402h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

;--------------------------------