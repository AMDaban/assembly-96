;_compute_sum(n, x) computes summation(k from 1 to n) of x^k/k! and stores the result in st4  

section .data
    x dq 5.e0
    n dq 3

section .text
    global _start                                          
_start:
    push qword [x]
    push qword [n]

    call _compute_sum
exit:
    mov ebx, 0
    mov eax, 1
    int 80h
;---------------------------------------

_compute_sum:                           ;_compute_sum(n, x) computes summation(k from 1 to n) of x^k/k! and stores the result in st4  
    enter 8, 0

    fldz
    fld qword [rbp + 24]
    fld1
    fld1
    fldz

    mov r8, 1
    mov [rbp - 8], r8
    main_loop:

        fild qword [rbp - 8]
        fmul st2
        fstp st2

        fld st2
        fmul st4
        fstp st3

        fld st2
        fdiv st2
        faddp st5, st0

        inc qword [rbp - 8]
        mov r8, [rbp - 8]
        cmp r8, [rbp + 16]
    jle main_loop

    leave 
    ret 16

;---------------------------------------
