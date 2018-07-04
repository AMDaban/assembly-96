section .data
    termios             times 36 db 0
    stdin               equ 0
    ICANON              equ 1 << 1
    ECHO                equ 1 << 3

    input_char          db 0
    expression_state    db 0
    first_operand_sign  db 0
    second_operand_sign db 0
    operation           db 0

    fn_length           db 0
    fn_dot              db 0
    fn_dot_read         db 0
    sn_length           db 0
    sn_dot              db 0
    sn_dot_read         db 0

    msg                 dq 0
    msglen              dq 0

    white_space         db ' '
    new_line            db 12

    number_max_size     equ 10

section .bss
    first_number        resb number_max_size
    second_number       resb number_max_size

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

        call check_char    

        jmp read_exp_loop

    ret
;--------------------------------

check_char:

    mov r8b, 'x'
    cmp r8b, [input_char]
    je exit

    mov r8b, '='
    cmp r8b, [input_char]
    jne check_char_not_equal
    call eval
    check_char_not_equal:

    mov r8b, 6
    cmp r8b, [expression_state]
    jle end_check_char

    mov r8b, ' '
    cmp r8b, [input_char]
    je end_check_char

    mov r8b, [expression_state]
    cmp r8b, 2
    jne check_char_state_not_2

    mov r8b, '+'
    cmp r8b, [input_char]
    jne not_plus

    mov r8b, 1
    mov [operation], r8b
    jmp state_2_finish

    not_plus:

    mov r8b, '-'
    cmp r8b, [input_char]
    jne not_minus

    mov r8b, 2
    mov [operation], r8b
    jmp state_2_finish

    not_minus:

    mov r8b, '*'
    cmp r8b, [input_char]
    jne not_mult

    mov r8b, 3
    mov [operation], r8b
    jmp state_2_finish

    not_mult:

    mov r8b, '/'
    cmp r8b, [input_char]
    jne not_div

    mov r8b, 4
    mov [operation], r8b
    jmp state_2_finish

    not_div:

    jmp end_check_char

    state_2_finish:

    mov r9b, [expression_state]
    inc r9b
    mov [expression_state], r9b

    jmp end_check_char

    check_char_state_not_2:

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

    end_check_char:
    ret

;--------------------------------
eval:
    mov al, [first_operand_sign]
    mov bl, [second_operand_sign]
    mov cl, [operation]
    x:
    call print_conf

    ret

;--------------------------------
print_conf:

    call print_new_line

    mov r8, first_number
    mov [msg], r8

    mov r8, number_max_size
    mov [msglen], r8

    call print_string

    call print_white_space

    mov r8, second_number
    mov [msg], r8

    mov r8, number_max_size
    mov [msglen], r8

    call print_string

    ret

;--------------------------------
print_new_line:

    mov r8, new_line
    mov [msg], r8

    mov r8, 1
    mov [msglen], r8

    call print_string

    ret

;--------------------------------
print_white_space:

    mov r8, white_space
    mov [msg], r8

    mov r8, 1
    mov [msglen], r8

    call print_string

    ret
;--------------------------------
extract_number:

    push rsi
    push rax
    push rbx
    push rcx
    
    mov r8b, 2
    cmp r8b, [expression_state]
    jne extract_number_state_not_1

    mov rsi, first_number
    mov rax, fn_length
    mov rbx, fn_dot
    mov rcx, fn_dot_read

    jmp extract_number_ready

    extract_number_state_not_1:

    mov rsi, second_number
    mov rax, sn_length
    mov rbx, sn_dot
    mov rcx, sn_dot_read

    extract_number_ready:

    call write_char

    extract_number_main_loop:
        mov r8b, [rax]
        cmp r8b, number_max_size
        je extract_number_end

        call read_single_char

        mov r8b, 'x'
        cmp r8b, [input_char]
        je exit

        mov r8b, [input_char]
        cmp r8b, '.'
        jne not_dot

        mov r8b, 1
        mov [rcx], r8b
        
        jmp extract_number_main_loop_end

        not_dot:

        mov r8b, '0'
        cmp r8b, [input_char]
        jg extract_number_not_a_number

        mov r8b, '9'
        cmp r8b, [input_char]
        jl extract_number_not_a_number

        jmp extract_number_number

        extract_number_not_a_number:

        call check_char
        jmp extract_number_end

        extract_number_number:

        call write_char

        extract_number_main_loop_end:
        jmp extract_number_main_loop

    extract_number_after_loop:

    extract_number_end:
    
    pop rcx
    pop rbx
    pop rax
    pop rsi

    ret
;--------------------------------
write_char:

    mov r8b, [input_char]
    mov byte [rsi], r8b

    inc rsi

    mov r8b, [rax]
    inc r8b
    mov [rax], r8b

    mov r8b, [rcx]
    cmp r8b, 0
    je no_dot

    mov r8b, [rbx]
    inc r8b
    mov [rbx], r8b

    no_dot:
    ret

;--------------------------------
prepare_for_calcaulation:

    mov byte [expression_state], 0
    mov byte [first_operand_sign], 0
    mov byte [second_operand_sign], 0
    mov byte [fn_length], 0
    mov byte [fn_dot], 0
    mov byte [fn_dot_read], 0
    mov byte [sn_length], 0
    mov byte [sn_dot], 0
    mov byte [sn_dot_read], 0
    mov byte [operation], 0

    ret    
;--------------------------------
read_single_char:

    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push rbx

    mov rax, 0
	mov rdi, 0
	mov rsi, input_char
	mov rdx, 2
	syscall

    pop rbx
    pop rcx
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

;-------------------------------------------

print_string:                              
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov eax, 4
    mov ebx, 1
    mov ecx, [msg]
    mov edx, [msglen]
 
    int 80h     

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax                            
    
    ret

;--------------------------------

; mov r8, first_number
; mov [msg], r8

; mov r8, number_max_size
; mov [msglen], r8

; call print_string