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

    minus_lit           db '-'
    is_res_neg          db 0

    fn_length           db 0
    fn_dot              db 0
    fn_dot_read         db 0
    sn_length           db 0
    sn_dot              db 0
    sn_dot_read         db 0

    fn_res              dq 0
    sn_res              dq 0

    msg                 dq 0
    msglen              dq 0

    pointer_to_number   dq 0
    string_length       db 0
    s_to_i_res          dq 0

    white_space         db ' '
    new_line            db 10

    ten_literal         dq 10
    minus_one           dq -1

    number_max_size     equ 10

    error_message       db '(Error)', 10
    error_message_len   equ $ - error_message

    oldControlWord      dw 0
    newControlWord      dw 0

    result              dq 0
    res_dot             db 0

    f1_flag             db 0
    f2_flag             db 0

section .bss
    first_number        resb number_max_size
    second_number       resb number_max_size

    final_result        resb 20

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
    jmp end_check_char
    
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

    push rax

    fstcw [oldControlWord]
    mov ax, [oldControlWord]
    and ah, 11110011b
    mov [newControlWord], ax
    fldcw [newControlWord]

    pop rax

    mov r8b, [fn_length]
    cmp r8b, 0
    jle eval_error

    mov r8b, [sn_length]
    cmp r8b, 0
    jle eval_error

    mov r8b, [operation]
    cmp r8b, 0
    jle eval_error

    jmp eval_ready

    eval_error:

    call print_error

    call prepare_for_calcaulation

    ret

    eval_ready:

    mov r8, first_number
    mov [pointer_to_number], r8

    mov r8b, [fn_length]
    mov [string_length], r8b

    call string_to_integer

    mov r8, [s_to_i_res]
    mov [fn_res], r8

    mov r8, second_number
    mov [pointer_to_number], r8

    mov r8b, [sn_length]
    mov [string_length], r8b

    call string_to_integer

    mov r8, [s_to_i_res]
    mov [sn_res], r8

    call calc

    call print_res

    ret
;--------------------------------
print_res:

    push rdx
    push rcx

    call print_new_line

    xor rdx, rdx
    mov dl, [fn_dot]
    mov r8b, [sn_dot]
    cmp dl, r8b
    jge its_ok

    mov dl, r8b

    its_ok:

    xor rcx, rcx
    mov cl, dl

    xor dl, dl

    cmp cx, 0
    je not_ok

    its_ok_loop:

        fild qword [ten_literal]
        fmul st1
        ffree st1

        inc dl

    loop its_ok_loop

    not_ok:

    fistp qword [result]
    mov [res_dot], dl

    call print_number

    call print_white_space

    pop rcx
    pop rdx

    ret
;--------------------------------
print_number:

    push rax
    push rdx
    push rsi

    mov rax, [result]
    cmp rax, 0
    jnl not_need_minus

    call print_minus
    neg rax
    mov [result], rax
    mov byte [is_res_neg], 1

    not_need_minus:

    xor rdx, rdx
    mov r11, 10000000000
    div r11
    mov rax, rdx

    mov rsi, final_result
    add rsi, 19

    xor r12, r12        ;length
    xor r13, r13        ;res_dot
    mov r13b, [res_dot]

    final_damn_loop:

        xor rdx, rdx
        mov r11, 10
        div r11

        add rdx, 48
        mov [rsi], dl
        dec rsi

        inc r12
        cmp r12, r13
        jne not_dot_needed

        mov byte [rsi], '.'
        dec rsi
        
        mov r14, 1
        mov [f1_flag], r14b

        cmp rax, 0
        jne not_damn_zero

        mov r14, 1
        mov [f2_flag], r14b

        not_damn_zero:

        not_dot_needed:

        cmp rax, 0
        jne final_damn_loop

    mov r8b, [f1_flag]
    cmp r8b, 0
    je is_damn_zero

    mov r9b, [f2_flag]
    cmp r9b, 0
    je is_damn_ok

    mov byte [rsi], '0'
    dec rsi
    inc r12
    jmp is_damn_ok

    is_damn_zero:

        cmp r13, 0
        je is_damn_ok

        damn_damn_loop:

        mov byte [rsi], '0'
        dec rsi
        inc r12

        cmp r12, r13
        je out_of_damn_damn_loop
        jmp damn_damn_loop

        out_of_damn_damn_loop:

        mov byte [rsi], '.'
        dec rsi

        mov byte [rsi], '0'
        dec rsi
        inc r12

    is_damn_ok:

    inc rsi

    mov [msg], rsi
    cmp r13, 0
    je not_dmn_needed
    inc r12
    not_dmn_needed:
    mov [msglen], r12
    call print_string

    call prepare_for_calcaulation
    mov byte [expression_state], 2

    mov r8b, [is_res_neg]
    mov byte [first_operand_sign], r8b

    mov r14, r12
    cmp r13, 0
    je not_dmn_needed_1
    dec r14
    not_dmn_needed_1:
    mov [fn_length], r14b
    
    mov [fn_dot], r13b

    mov rcx, r12
    mov rdi, first_number
    mov r15, 0
    loop_damn:

    mov r8b, [rsi]
    inc rsi
    cmp r8b, '.'
    je end_looop

    mov [rdi], r8b
    inc rdi
    inc r15

    cmp r15, 10
    je aaffteer

    end_looop:
    loop loop_damn

    aaffteer:

    pop rsi
    pop rdx
    pop rax

    ret
;--------------------------------
calc:
    push rcx

    xor rcx, rcx
    mov cl, [fn_dot]

    fild qword [fn_res]
    fild qword [ten_literal]

    cmp cl, 0
    je calc_not_have_zero

    calc_1_loop:

        fdiv st1, st0

    loop calc_1_loop

    calc_not_have_zero:

    mov r8b, [first_operand_sign]
    cmp r8b, 0
    je first_not_minus

    fild qword [minus_one]
    fmul st2, st0
    faddp st1, st0

    first_not_minus:

    xor rcx, rcx
    mov cl, [sn_dot]

    fild qword [sn_res]
    fild qword [ten_literal]

    cmp cl, 0
    je calc_not_have_zero_1

    calc_2_loop:

        fdiv st1, st0

    loop calc_2_loop

    calc_not_have_zero_1:

    mov r8b, [second_operand_sign]
    cmp r8b, 0
    je second_not_minus

    fild qword [minus_one]
    fmul st2, st0
    faddp st1, st0

    second_not_minus:

    fldz
    fadd st0, st2

    fldz
    fadd st0, st5

    mov r8b, [operation]
    cmp r8b, 1
    jne calc_not_sum

    fadd st0, st1
    jmp end_calc

    calc_not_sum:

    mov r8b, [operation]
    cmp r8b, 2
    jne calc_not_minus

    fsub st0, st1
    jmp end_calc

    calc_not_minus:

    mov r8b, [operation]
    cmp r8b, 3
    jne calc_not_mult

    fmul st0, st1
    jmp end_calc

    calc_not_mult:

    mov r8b, [operation]
    cmp r8b, 4
    jne calc_not_div

    mov r9, [sn_res]
    cmp r9, 0
    je div_zero

    fdiv st0, st1
    jmp end_calc

    div_zero:
    
    call print_error
    fldz

    calc_not_div:

    end_calc:

    ffree st1
    ffree st2
    ffree st3
    ffree st4
    ffree st5
    pop rcx

    ret

;--------------------------------
print_error:

    call print_white_space

    mov r8, error_message
    mov [msg], r8

    mov r8, error_message_len
    mov [msglen], r8

    call print_string

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
print_minus:

    mov r8, minus_lit
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
    mov byte [string_length], 0
    mov qword [pointer_to_number], 0
    mov qword [s_to_i_res], 0
    mov qword [result], 0
    mov qword [res_dot], 0
    mov byte [f1_flag], 0
    mov byte [f2_flag], 0
    mov byte [is_res_neg], 0
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

string_to_integer:

    push rsi 
    push rcx
    push rax

    mov rsi, [pointer_to_number]

    xor r8, r8
    mov r8b, [string_length]
    add rsi, r8
    dec rsi

    xor r8, r8
    mov r8b, [string_length]
    mov rcx, r8

    mov r9, 1

    xor r10, r10

    stringtointegerloop_mainloop:

        xor r11, r11 
        mov r11b, [rsi]
        sub r11b, 48

        mov rax, r11
        mul r9
        add r10, rax

        jno notoverflow

        xor rax, rax
        pop rcx
        pop rsi
        ret

        notoverflow:
        mov rax, r9
        mov r11, 10
        mul r11
        mov r9, rax

        dec rsi

    loop stringtointegerloop_mainloop

    mov rax, r10
    mov [s_to_i_res], rax

    pop rax
    pop rcx
    pop rsi

    ret

;-------------------------------------------