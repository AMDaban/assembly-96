;_bit_count counts the number of bits with 1 value in rax and store it in bl

section .data
     target_rax dq 0x9999888899998888
section .text
    global _start
_start:
    
    mov rax, [target_rax]

    call _bit_count

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

_bit_count:                 ;_bit_count counts the number of bits with 1 value in rax and store it in bl

    mov r8, rax             ;store previous values
    mov r9, rcx
    mov r10, rdx
    
    xor rbx, rbx            ;clear rbx, result will be in bl
    xor rcx, rcx
    xor rdx, rdx

    main_loop:

        bsf rcx, rax        ;find least significant 1 in rax
        jz return           ;if no 1 found, goto end
        btc rax, rcx        ;clear the used bit
        inc bl

    jmp main_loop

    return:
    mov rax, r8             ;restore previous values
    mov rcx, r9
    mov rdx, r10

    ret

;---------------------------