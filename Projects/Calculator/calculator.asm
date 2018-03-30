section .data
    msg dq 0                                ;string address which will be written
    msglen dq 0                             ;string length which will be written

    first_message db 'Simple Calculator: (write a simple expression)', 10
    first_message_len equ $ - first_message

    exp_max_size equ 50                     ;expression max size
    integer_max_size equ 19                 ;integer max size

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

    call _evaluate_string

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;-------------------------------------------

_print_string:                              ;simply print the string with length msglen that its address stored in msg
    
    mov eax, 4                              ;'write' system call
    mov ebx, 1                              ;file descriptor 1 = screen
    mov ecx, [msg]                          ;string to write       
    mov edx, [msglen]                       ;length of string to write
 
    int 80h                                 ;call the kernel
    
    ret

;-------------------------------------------

_get_user_input:                            ;simply get user input and store it in the input array(max length = 100 character)

    mov rax, 0                              ;'read' system call
    mov rdi, 0                              ;standard input
    mov rsi, input                          ;input will be in input array 
    mov rdx, exp_max_size                   ;max length of input
    
    syscall                                 ;call the kernel

    ret

;-------------------------------------------

_clear_input_array:                         ;clear input array

    mov rcx, exp_max_size
    mov esi, input
    clearinputloop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearinputloop

    ret
;-------------------------------------------

_clear_number_chars_array:                  ;clear number_chars array

    mov rcx, integer_max_size
    mov esi, number_chars
    clearnumbercharsloop:
        xor r8, r8
        mov [esi], r8b
        inc esi
    loop clearnumbercharsloop

    ret
;-------------------------------------------

_string_to_integer:                         ;convert string which is in number_chars to (unsigned)integer(stored in rax)

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

        xor rax, rax
        ret

        notoverflow:
        mov rax, r9
        mov r11, 10
        mul r11
        mov r9, rax

        dec esi

    loop stringtointegerloop_mainloop

    mov rax, r10

    ret

;-------------------------------------------

_evaluate_string:                           ;evaluate string stored in expression

    mov rcx, exp_max_size
    mov esi, expression

    xor r8, r8
    mov r8b, 0                              ;specify operation(1 -> +, 2 -> -, 3 -> *, 4 -> /)

    xor r10, r10

    evaluatestring_mainloop:
        mov al, [esi]
        cmp [esi], byte 0
        je end_evaluatestring_mainloop

        cmp [esi], byte 43                  ;+ read
        mov r10, 1
        cmove r8, r10

        cmp [esi], byte 45                  ;- read
        mov r10, 2
        cmove r8, r10

        cmp [esi], byte 42                  ;* read
        mov r10, 3
        cmove r8, r10

        cmp [esi], byte 47                  ;/ read
        mov r10, 4
        cmove r8, r10

    end_evaluatestring_mainloop:
        inc esi
    loop evaluatestring_mainloop

    ret

;-------------------------------------------
_copy_input_array_to_expression_array:      ;copy input into expression

    mov rcx, exp_max_size
    mov esi, input
    mov edi, expression
    
    copyinputarraytoexpressionarray_mainloop:

    mov al, [esi]
    mov [edi], al

    inc esi
    inc edi 

    loop copyinputarraytoexpressionarray_mainloop

    ret
;-------------------------------------------