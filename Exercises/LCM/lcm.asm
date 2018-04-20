;compute GCD of first(rax) and second(rbx) operands and store the result in rdx
;we assume that numbers in rax, rbx are unsigned

section .data
    firstOperand dq 20 
    ;first operand
    
    secondOperand dq 12      
    ;second operand

section .text
    global _start
_start:
    mov rax, [firstOperand]
    mov rbx, [secondOperand]

    call computeLCM

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

computeGCD:                 ;compute GCD of first(rax) and second(rbx) operands and store the result in rdx

    xor rdx, rdx            ;clear rdx

    cmp rax, 0              ;jump out if rax = 0 or rbx = 0 
    jne ax_not_zero
        mov rdx, rbx
        ret
    ax_not_zero:

    cmp rbx, 0
    jne bx_not_zero
        mov rdx, rax
        ret
    bx_not_zero:

    xor r8, r8              ;clear r8
    xor r9, r9              ;clear r9

    cmp rax, rbx            ;compare two operand to see which one is greater

    cmovg r8, rax           ;if rax > rbx then r8 <- rax, r9 <- rbx
    cmovg r9, rbx
    
    cmovng r8, rbx          ;if rax <= rbx then r8 <- rbx, r9 <- rax
    cmovng r9, rax

    mov rcx, 1              ;loop controller

cgcdmainloop:

    inc rcx                 

    xor rdx, rdx            ;divide two actual number
    mov rax, r8
    div r9

    mov r8, r9        
    mov r9, rdx

    cmp r9, 0               ;if the remainder is 0 then break the loop
    loopne cgcdmainloop

    mov rdx, r8             ;move result to dx

    ret

;---------------------------

computeLCM:                 ;compute LCM of first(rax) and second(rbx) operands and store the result in rdx

    xor rdx, rdx

    cmp rax, 0
    je return

    cmp rbx, 0
    je return

    mov r11, rax            ;save first operand in r8
    mov r12, rbx            ;save second operand in r9

    call computeGCD         ;compute GCD

    mov r10, rdx            ;save GCD in r10            

    mov rax, r11            ;compute r8 * r9
    mul r12

    div r10                 ;divide by GCD

    mov rdx, rax            ;move LCM to rdx
return:
    ret