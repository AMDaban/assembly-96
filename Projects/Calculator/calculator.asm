section .data
    msg dq 0                                ;string address which will be written
    msglen dq 0                             ;string length which will be written

    first_message db 'Simple Calculator: (write a simple expression)', 10
    first_message_len equ $ - first_message

    error_message db 'bad expression', 10
    error_message_len equ $ - error_message

    overflow_message db 'overflow', 10
    overflow_message_len equ $ - overflow_message

    exp_max_size equ 50                     ;expression max size
    integer_max_size equ 19                 ;integer max size

    first_operand dq 0                      ;first operand in expression
    second_operand dq 0                     ;second operand in expression
    numbers_read db 0                       ;numbers read in expression
    operation db 0                          ;specify operation(1 -> +, 2 -> -, 3 -> *, 4 -> /)

    number_length db 0                      ;length of output number

section .bss
    input resb exp_max_size                 ;user input
    number_chars resb integer_max_size      ;characters that specify a number
    expression resb exp_max_size

section .text
    global _start                                          
_start:

    mov rax, first_message                  ;print first_message
    mov [msg], rax
    mov rax, first_message_len
    mov [msglen], rax
    call _print_string

    call _clear_input_array
    call _clear_number_chars_array

    call _get_user_input                    ;get first user input

    call _copy_input_array_to_expression_array

    call _evaluate_string                   ;evaluate first expression

    call _clear_expression_array
    call _clear_input_array
    call _clear_number_chars_array

    call _copy_bcdnumber

    mov rax, expression                     ;print first_message
    mov [msg], rax
    mov rax, [number_length]
    mov [msglen], rax
    call _print_string

    mov [number_length], byte 0

    call _get_user_input

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;-------------------------------------------

_print_string:                              ;simply print the string with length msglen that its address stored in msg
    
    mov r8d, eax                            ;store previous values
    mov r9d, ebx
    mov r10d, ecx
    mov r11d, edx  

    mov eax, 4                              ;'write' system call
    mov ebx, 1                              ;file descriptor 1 = screen
    mov ecx, [msg]                          ;string to write       
    mov edx, [msglen]                       ;length of string to write
 
    int 80h                                 ;call the kernel
    
    mov eax, r8d                            ;restore previous values
    mov ebx, r9d
    mov ecx, r10d
    mov edx, r11d
    ret

;-------------------------------------------

_get_user_input:                            ;simply get user input and store it in the input array(max length = 100 character)

    mov r8, rax                             ;store previous values
    mov r9, rdi
    mov r10, rsi
    mov r11, rdx 

    mov rax, 0                              ;'read' system call
    mov rdi, 0                              ;standard input
    mov rsi, input                          ;input will be in input array 
    mov rdx, exp_max_size                   ;max length of input
    
    syscall                                 ;call the kernel

    mov rax, r8                             ;restore previous values
    mov rdi, r9
    mov rsi, r10
    mov rdx, r11
    ret

;-------------------------------------------

_clear_expression_array:                         ;clear input array
    
    mov r9, rcx                             ;store previous values
    mov r10d, esi

    mov rcx, exp_max_size
    mov esi, expression
    clearexploop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearexploop

    mov rcx, r9                             ;restore previous values
    mov esi, r10d
    ret

;-------------------------------------------

_clear_input_array:                         ;clear input array
    
    mov r9, rcx                             ;store previous values
    mov r10d, esi

    mov rcx, exp_max_size
    mov esi, input
    clearinputloop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearinputloop

    mov rcx, r9                             ;restore previous values
    mov esi, r10d
    ret
;-------------------------------------------

_clear_number_chars_array:                  ;clear number_chars array

    mov r9, rcx                             ;store previous values
    mov r10d, esi 

    mov rcx, integer_max_size
    mov esi, number_chars
    clearnumbercharsloop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearnumbercharsloop

    mov rcx, r9                             ;restore previous values
    mov esi, r10d
    ret
;-------------------------------------------

_string_to_integer:                         ;convert string which is in number_chars to (unsigned)integer(stored in rax)

    mov r12d, esi                           ;store previous values
    mov r14, rcx

    mov esi, number_chars       
    mov rcx, integer_max_size
    xor r8, r8                              ;store number of digits

    stringtointegerloop_countdigits:        
                                            ;count number of digits (will be stored in r8d)
        
        cmp [esi], byte 0                   ;check if [esi] is a number or not(if [esi] is 0 then it is not a number)
        
        je digitnotexists
        
        inc r8d
        
        digitnotexists:
        inc esi
    
    loopne stringtointegerloop_countdigits

    mov esi, number_chars
    add esi, r8d
    dec esi
    mov rcx, r8
    mov r9, 1
    xor r10, r10 

    stringtointegerloop_mainloop:           ;convert string to integer (overflow : rax <- 0 )

        xor r11, r11 
        mov r11b, [esi]
        sub r11b, 48

        mov rax, r11
        mul r9
        add r10, rax

        jno notoverflow

        xor rax, rax                        ;restore previous values
        mov esi, r12d
        mov rcx, r14
        ret

        notoverflow:
        mov rax, r9
        mov r11, 10
        mul r11
        mov r9, rax

        dec esi

    loop stringtointegerloop_mainloop

    mov rax, r10

    mov esi, r12d                           ;restore previous values
    mov rcx, r14
    ret

;-------------------------------------------

_evaluate_string:                           ;evaluate string stored in expression(result will be in rax)

    mov r12d, esi                           ;store previous values
    mov r13, rcx

    mov rcx, exp_max_size
    mov esi, expression

    xor r8, r8
    mov r8b, 0                              ;specify operation(1 -> +, 2 -> -, 3 -> *, 4 -> /)

    xor r10, r10                            ;auxiliary register

    evaluatestring_mainloop:
        
        cmp [esi], byte 101                 ;exit read
        je exit

        cmp [esi], byte 43                  ;+ read
        mov r10b, 1
        jne evaluatestring_notequal_plus
        mov [operation], r10b
        evaluatestring_notequal_plus:
        je end_evaluatestring_mainloop

        cmp [esi], byte 45                  ;- read
        mov r10b, 2
        jne evaluatestring_notequal_minus
        mov [operation], r10b
        evaluatestring_notequal_minus:
        je end_evaluatestring_mainloop

        cmp [esi], byte 42                  ;* read
        mov r10b, 3
        jne evaluatestring_notequal_mult
        mov [operation], r10b
        evaluatestring_notequal_mult:
        je end_evaluatestring_mainloop

        cmp [esi], byte 47                  ;/ read
        mov r10b, 4
        jne evaluatestring_notequal_div
        mov [operation], r10b
        evaluatestring_notequal_div:
        je end_evaluatestring_mainloop

        cmp [esi], byte 48                  ;check if the digit is a number(it must be between 48, 57)
        jl  end_evaluatestring_mainloop
    
        cmp [esi], byte 57
        jg  end_evaluatestring_mainloop

        call _extract_integer
        
        call _fill_operands

    end_evaluatestring_mainloop: 
        inc esi
    loop evaluatestring_mainloop

    xor rax, rax
    
    cmp [first_operand], byte 0
    je evaluatestring_error

    cmp [operation], byte 0
    je evaluatestring_error

    cmp [second_operand], byte 0
    je evaluatestring_error

    cmp [operation], byte 1
    jne evaluatestring_notplus
    mov rax, [first_operand]
    add rax, [second_operand]
    jno evaluatestring_return

    xor rax, rax
    call _print_overflow

    jmp evaluatestring_return

    evaluatestring_notplus:

    cmp [operation], byte 2
    jne evaluatestring_notminus
    mov rax, [first_operand]
    sub rax, [second_operand]
    jno evaluatestring_return

    xor rax, rax
    call _print_overflow

    jmp evaluatestring_return

    evaluatestring_notminus:

    cmp [operation], byte 3
    jne evaluatestring_notmult
    mov rax, [first_operand]
    mov rbx, [second_operand]
    mul rbx
    jno evaluatestring_return

    xor rax, rax
    call _print_overflow

    jmp evaluatestring_return

    evaluatestring_notmult:

    cmp [operation], byte 4
    jne evaluatestring_notdivide
    xor rdx, rdx
    mov rax, [first_operand]
    mov rbx, [second_operand]
    div rbx
    jno evaluatestring_return

    xor rax, rax
    call _print_overflow

    jmp evaluatestring_return

    evaluatestring_notdivide:

    evaluatestring_error:
    mov rax, error_message                  ;print error_message
    mov [msg], rax
    mov rax, error_message_len
    mov [msglen], rax
    call _print_string

    xor rax, rax

    evaluatestring_return:
    mov esi, r12d                           ;restore previous values
    mov rcx, r13
    ret

;-------------------------------------------

_fill_operands:

    cmp [numbers_read], byte 0
    jne evaluatestring_notequal
    mov [first_operand], rax
    jmp evaluatestring_addtonumbersread
    evaluatestring_notequal:
    mov [second_operand], rax
    evaluatestring_addtonumbersread:
    add [numbers_read], byte 1

    ret

;-------------------------------------------

_extract_integer:

    mov r10d, edi                           ;store previous values
    mov r11, rbx

    mov rbx, rcx

    mov edi, number_chars
    mov rcx, integer_max_size

    call _clear_number_chars_array

    extractinteger_mainloop:
    
    cmp [esi], byte 48                      ;check if the digit is a number(it must be between 48, 57)
    jl  extractinteger_finilize
    
    cmp [esi], byte 57
    jg  extractinteger_finilize

    mov al, [esi]
    mov [edi], al

    inc esi
    dec rbx

    inc edi

    cmp rbx, 0
    je extractinteger_finilize

    loop extractinteger_mainloop

extractinteger_finilize:

    call _string_to_integer

    inc rbx
    mov rcx, rbx

    dec esi 

    mov edi, r10d                           ;restore previous values
    mov rbx, r11

    ret

;-------------------------------------------
_copy_input_array_to_expression_array:      ;copy input into expression

    mov r8, rcx
    mov r9d, esi
    mov r10d, edi

    mov rcx, exp_max_size
    mov esi, input
    mov edi, expression
    
    copyinputarraytoexpressionarray_mainloop:

    mov al, [esi]
    mov [edi], al

    inc esi
    inc edi 

    loop copyinputarraytoexpressionarray_mainloop

    mov rcx, r8
    mov esi, r9d
    mov edi, r10d

    ret
;-------------------------------------------
_print_overflow:

    mov r9, rax                             ;store previous values   

    mov rax, overflow_message               ;print overflow_message
    mov [msg], rax
    mov rax, overflow_message_len
    mov [msglen], rax
    call _print_string

    mov rax, r9                             ;restore previous valuse
    ret
;-------------------------------------------
_copy_bcdnumber:

    mov r10, rsi                             ;store previous values

    mov r8, rax
    mov esi, expression

    copybcdnumber_mainloop:

    xor rdx, rdx
    mov rax, r8
    mov r9, 10
    div r9

    add rdx, 48
    mov [esi], dl

    inc esi
    mov r8, rax
    mov r9b, [number_length]
    inc r9b
    mov [number_length], r9b

    cmp r8, 0
    jne copybcdnumber_mainloop

    mov [esi], byte 32
    mov r9b, [number_length]
    inc r9b
    mov [number_length], r9b

    mov rsi, r10                             ;restore previous valuse
    ret
;-------------------------------------------    