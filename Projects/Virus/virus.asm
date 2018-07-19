section .text
    global _start                                          
_start:

exit:
    mov ebx, 0
    mov eax, 1
    int 80h
