;_multiplication computes the multiplication of eax, ebx and store result in rdx

section .data
    first_operand dd -2147483647
    second_operand dd 2147483647

section .text
    global _start                                          
_start:

    xor rax, rax
    mov eax, [first_operand]

    xor rbx, rbx
    mov ebx, [second_operand] 

    call _multiplication

exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_multiplication:                        ;_multiplication computes the multiplication of eax, ebx and store result in rdx

    mov r9, rax                         ;store previous values

    xor r8, r8                          ;r8 is 1 iff al * bl < 0

    cmp eax, 0                          ;check first operand
    jge first_operand_not_negative
        inc r8
        neg eax
    first_operand_not_negative:

    cmp ebx, 0                          ;check second operand
    jge second_operand_not_negative
        inc r8
        neg ebx
    second_operand_not_negative:

    xor r10, r10                        ;r10 = ebx but it has 64 bits
    mov r10d, ebx

    xor rdx, rdx                        ;clear rdx, result will be in rdx

    main_loop:
        cmp eax, 0                       ;jump out if eax is 0
        je return 

        dec eax
        add rdx, r10
    jmp main_loop

    return:
    cmp r8, 1                           
    jne result_not_negative             ;negative the number if necessary
        neg rdx
    result_not_negative:
    mov rax, r9                         ;restore previous values
    ret

;---------------------------------------
