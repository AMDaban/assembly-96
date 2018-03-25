;we treat ax az an unsigned number, the sum of evens will be in bx and the other will be in dx
section .data
    number dw 63458         ;target number(we want to compute the sum of its digits)
section .text
    global _start
_start:
    mov ax, [number]        ;move number to ax register(this is not a part of the assignment)

    xor r8, r8
    mov r8w, ax             ;read contents of rax and store it in r8
    xor r9, r9              ;the sum of the even digits will be in r9
    xor r10, r10            ;the sum of the odd digits will be in r10

    mov r11, 10             ;just a constant
    mov r13, 2              ;just another constant
    mov rcx, 1              ;loop controller

mainloop:
    inc rcx                 ;just controls the loop

    xor dx, dx              ;divide actual number by 10 and execute proper instructions
    mov ax, r8w
    div r11
    
    xor r8, r8              ;reassign for next itteration
    mov r8w, ax

    xor r12, r12            ;store digit in r12w
    mov r12w, dx

    xor dx, dx              ;check if the digit is even or odd
    mov ax, r12w
    div r13
    
    cmp dx, 0
    je evendigit

    add r10w, r12w
    jmp endloop
    
evendigit:
    add r9w, r12w    

endloop:
    cmp r8, 0               ;if the actual number became 0 then break the loop
    loopne mainloop

    mov dx, r9w             ;store final result in dx

exit:
    mov ebx, 0
    mov eax, 1
    int 80h
