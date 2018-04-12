;computeGCD computes GCD of first(ax) and second(bx) operands and store the result in dx
;we assume that numbers in ax, bx are unsigned
;0 <= firstOperand, secondOperand <= 2^16 - 1 

section .data
    firstOperand dw 165     ;first operand
    secondOperand dw 385    ;second operand 
section .text
    global _start
_start:
    mov ax, [firstOperand]
    mov bx, [secondOperand]

    call computeGCD

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

computeGCD:                 ;compute GCD of first(ax) and second(bx) operands and store the result in dx
    
    xor rdx, rdx            ;clear rdx

    cmp ax, 0               ;jump out if ax = 0 or bx = 0 
    je exit

    cmp bx, 0
    je exit

    xor r8, r8              ;clear r8
    xor r9, r9              ;clear r9

    cmp ax, bx              ;compare two operand to see which one is greater

    cmovg r8w, ax           ;if ax > bx then r8w <- ax, r9w <- bx
    cmovg r9w, bx
    
    cmovng r8w, bx          ;if ax <= bx then r8w <- bx, r9w <- ax
    cmovng r9w, ax

    mov rcx, 1              ;loop controller

cgcdmainloop:

    inc rcx                 

    xor dx, dx              ;divide two actual number
    mov rax, r8
    div r9w

    mov r8w, r9w        
    mov r9w, dx

    cmp r9w, 0              ;if the remainder is 0 then break the loop
    loopne cgcdmainloop

    mov dx, r8w             ;move result to dx

    ret
;---------------------------