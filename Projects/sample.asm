section .data

    msg                 db "fine", 0

section .text
    global _start

_start:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 5
    int 80h

exit:
    mov eax, 1
    mov ebx, 0
    int 80h