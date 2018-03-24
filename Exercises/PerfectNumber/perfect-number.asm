section .data
    number dq 8128          ;target number(we want to see if it is a perfect number or not)
section .text
    global _start
_start:
    mov rax, [number]       ;move number to rax register(this is not a part of the assignment)

    mov r8, rax             ;read contents of rax and store it in r8
    mov r9, 1               ;the sum of the divisors will be in r9(1 is a trivial divisor)
    mov r10, 1              ;begin from 2 and check all numbers <= sqrt(number) (incremented in loop)
    
    mov r11, 1              ;just a constant
    mov rcx, 1              ;loop controller
    mov r12, 0              ;clear r12

    cmp r8, 1               ;jump out if number is one(special case)
    je exit

mainloop:
    inc rcx                 ;we don't want the loop broken

    inc r10                 ;increment r10(mentioned before)

    xor rdx, rdx
    mov rax, r10            ;two following statments computes counter * counter (r10 * 10)    
    mul rax
    
    cmp rdx, 0              ;jump out if the number is bigger than 64 bit
    cmovne rcx, r11
    jne endloop

    cmp rax, 0              ;jump out if the number is bigger than 64 bit
    cmovl rcx, r11
    jl endloop

    cmp r8, rax             ;compare result and the actual number
    cmovng rcx, r11         ;if result > actual number then break the loop(rcx <- 1)
    jng endloop

    xor rdx, rdx            ;these lines(40 - 51) check and add proper divisors to the result (r9)
    mov rax, r8
    div r10
    
    cmp rdx, 0
    jne endloop

    add r9, r10
    xor rdx, rdx
    mov rax, r8
    div r10
    add r9, rax

endloop:
    loop mainloop

    mov rax, r10    
    mul rax
    cmp r8, rax
    jne finilize
    add r9, r10

finilize:
    cmp r8, r9              ;produce the answer(the answer is in r12: if r12 is 1 then the input is a perfect number)
    cmove r12, r11

exit:
    mov ebx, 0
    mov eax, 1
    int 80h