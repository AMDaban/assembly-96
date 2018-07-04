section .data
    termios             times 36 db 0
    stdin               equ 0
    ICANON              equ 1 << 1
    ECHO                equ 1 << 3

    input_char          db 0
    expression_state    db 0
    first_operand_sign  db 0
    second_operand_sign db 0

section .text
    global _start                                          
_start:
    call canonical_off

start_calculation:
    call prepare_for_calcaulation
    call read_exp

exit:
    call canonical_on
    
    mov ebx, 0
    mov eax, 1
    int 80h
;--------------------------------
read_exp:

    read_exp_loop:
        call read_single_char

        mov r8b, 'x'
        cmp r8b, [input_char]

        ; mov al, [first_operand_sign]
        ; mov bl, [second_operand_sign]

        je exit

        mov r8b, ' '
        cmp r8b, [input_char]
        je end_read_exp_loop

        mov r8b, 0
        cmp r8b, [expression_state]
        je status_is_0_or_3

        mov r8b, 3
        cmp r8b, [expression_state]
        je status_is_0_or_3

        jmp status_is_not_0_3

        status_is_0_or_3:

            mov r8b, '-'
            cmp r8b, [input_char]
            jne sign_is_not_minus

            mov r8b, 0
            cmp r8b, [expression_state]
            jne status_is_3

            mov byte [first_operand_sign], 1
            
            mov r9b, [expression_state]
            inc r9b
            mov [expression_state], r9b

            jmp status_is_not_0_3

            status_is_3:
                    
            mov byte [second_operand_sign], 1

            mov r9b, [expression_state]
            inc r9b
            mov [expression_state], r9b

            jmp status_is_not_0_3

            sign_is_not_minus:

            mov r8b, '+'
            cmp r8b, [input_char]
            jne status_is_not_0_3

            mov r9b, [expression_state]
            inc r9b
            mov [expression_state], r9b

        status_is_not_0_3:

        mov r8b, '0'
        cmp r8b, [input_char]
        jg not_a_number

        mov r8b, '9'
        cmp r8b, [input_char]
        jl not_a_number

        mov r8b, 0
        cmp r8b, [expression_state]
        je have_to_inc

        mov r8b, 3
        cmp r8b, [expression_state]
        je have_to_inc

        jmp not_have_to_inc

        have_to_inc:

        mov r9b, [expression_state]
        inc r9b
        mov [expression_state], r9b

        not_have_to_inc:

        mov r9b, [expression_state]
        inc r9b
        mov [expression_state], r9b

        call extract_number

        not_a_number:

        end_read_exp_loop:
        jmp read_exp_loop

    ret
;--------------------------------
extract_number:

    ret    
;--------------------------------
prepare_for_calcaulation:

    mov byte [expression_state], 0
    mov byte [first_operand_sign], 0
    mov byte [second_operand_sign], 0

    ret    
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