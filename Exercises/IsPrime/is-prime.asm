;_is_prime checks if the number stored in rax is a prime number and if it is, put 1 in rbx otherwise put 0 in it
;the answer will be in rbx as a boolean (1 if the actual number is prime)
;we treat rax az an unsigned number

section .data
    number dq 7917          ;target number(we want to see if it is a prime number or not)
section .text
    global _start
_start:
    mov rax, [number]       ;move number to rax register(this is not a part of the assignment)

    call _is_prime

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

_is_prime:                  ;_is_prime checks if the number stored in rax is a prime number and if it is, put 1 in rbx otherwise put 0 in it

    mov r8, rax             ;read contents of rax and store it in r8(actual number)
    mov rbx, 1              ;result will be stored here az a boolean (1 if the actual number is prime)
    mov r10, 1              ;begin from 2 and check all numbers <= sqrt(number) (incremented in loop)
    
    mov r11, 1              ;just a constant
    mov r12, 0              ;just an another constant
    mov rcx, 1              ;loop controller

    cmp r8, 0               ;jump out if number is zero(special case)
    cmove rbx, r12
    je exit

    cmp r8, 1               ;jump out if number is one(special case)
    cmove rbx, r12
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
    cmovl rcx, r11          ;if result > actual number then break the loop(rcx <- 1)
    jl endloop

    xor rdx, rdx            ;check if r10 is a divisor or not
    mov rax, r8
    div r10
    cmp rdx, 0              ;if r10 is a divisor then break the loop and mark actual number az a prime number
    cmove rcx, r11
    cmove rbx, r12

endloop:
    loop mainloop

    ret

;---------------------------
