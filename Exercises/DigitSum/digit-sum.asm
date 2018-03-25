;we treat ax az an unsigned number, the answer will be in dx after the computation
section .data
    number dw 11         ;target number(we want to compute the sum of its digits)
section .text
    global _start
_start:
    mov ax, [number]        ;move number to ax register(this is not a part of the assignment)

    xor r8, r8
    mov r8w, ax             ;read contents of rax and store it in r8
    xor r9, r9              ;the sum of the digits will be in r9

    mov r11, 10             ;just a constant
    mov rcx, 1              ;loop controller

mainloop:
    inc rcx                 ;just controls the loop

    xor dx, dx              ;divide actual number by 10 and execute proper instructions
    mov ax, r8w
    div r11
    add r9w, dx
    xor r8, r8
    mov r8w, ax

    cmp r8, 0               ;if the actual number became 0 then break the loop
    loopne mainloop

    mov dx, r9w             ;store final result in dx

exit:
    mov ebx, 0
    mov eax, 1
    int 80h