;_multiplication computes the multiplication of al, bl and store result in dx

section .data
    first_operand db -123
    second_operand db 100

section .text
    global _start                                          
_start:

    xor rax, rax
    mov al, [first_operand]

    xor rbx, rbx
    mov bl, [second_operand] 

    call _multiplication

exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_multiplication:                        ;_multiplication computes the multiplication of al, bl and store result in dx

    mov r9, rax                         ;store previous values

    xor r8, r8                          ;r8 is 1 iff al * bl < 0

    cmp al, 0                           ;check first operand
    jge first_operand_not_negative
        inc r8
        neg al
    first_operand_not_negative:

    cmp bl, 0                           ;check second operand
    jge second_operand_not_negative
        inc r8
        neg bl
    second_operand_not_negative:

    xor r10, r10                        ;r10w = bl but it has 16 bits
    mov r10b, bl

    xor rdx, rdx                        ;clear rdx, result will be in dx

    main_loop:
        cmp al, 0                       ;jump out if al is 0
        je return 

        dec al
        add dx, r10w
    jmp main_loop

    return:
    cmp r8, 1                           
    jne result_not_negative             ;negative the number if necessary
        neg dx
    result_not_negative:
    mov rax, r9                         ;restore previous values
    ret

;---------------------------------------
