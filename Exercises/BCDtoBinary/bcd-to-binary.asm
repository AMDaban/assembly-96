;BCDtoBinary
;_bcd_to_binary converts a 16 digit (or less) unsigned number stored in rax to binary and store it in rbx 

section .data
    target_number dq 0x9876543212345678 ;target number
    max_number_of_digits equ 16

section .text
    global _start                                          
_start:
    mov rax, [target_number]

    call _bcd_to_binary
exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_bcd_to_binary:                         ;convert a 16 digit unsigned number stored in rax to binary and store it in rbx

    mov r8, rcx                         ;store previous values
    mov r9, rdx
    mov r10, rax
    
    xor rbx, rbx                        ;clear rbx, rdx
    xor rdx, rdx

    mov r11, rax                        ;keep target_number in r11

    mov r12, 1                          ;constants
    mov r13, 10

    mov rcx, max_number_of_digits       ;set loop counter

    bcdtobinary_mainloop:

        mov dl, r11b                    ;in two following instructions, we extract next digit
        and dl, 0x0f

        xor rax, rax                    ;clear rax
        mov al, dl                      ;make correct value
        mul r12

        add rbx, rax

        shr r11, 4                      ;remove last digit

        mov rax, r12                    ;r12 = r12 * 10             
        mul r13
        mov r12, rax
    
    loop bcdtobinary_mainloop

    mov rcx, r8                         ;restore previous values
    mov rdx, r9
    mov rax, r10

    ret

;---------------------------------------
