;_bitwise_reverse reverses the arrange of the bits in rax and stores result in rdx

section .data
     target_rax dq 0x8880888888888888
section .text
    global _start
_start:
    
    mov rax, [target_rax]

    call _bitwise_reverse

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

_bitwise_reverse:           ;_bitwise_reverse reverses the arrange of the bits in rax and stores result in rdx

    mov r8, rax             ;store previous values
    mov r9, rcx
    mov r10, rbx

    mov rdx, rdx            ;clear rdx, result will be in rdx
    xor rcx, rcx            ;clear rcx

    main_loop:

    mov rbx, 63             ;number of bits

    bsf rcx, rax            ;find least significant 1 in rax
    jz return               ;if no 1 found, goto end
    sub rbx, rcx            ;compute the corresponding bit
    bts rdx, rbx            ;set the corresponding bit in rdx
    btc rax, rcx            ;clear the used bit

    jmp main_loop           ;do this process again

    return:
    mov rax, r8             ;restore previous values
    mov rcx, r9
    mov rbx, r10

    ret

;---------------------------