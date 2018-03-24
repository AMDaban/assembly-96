; program Add
section .data
    d1 db 12
    d2 db 50
    d3 db 0
section .text
    global _start
_start:
    mov al, [d1]
    add al, [d2]
    mov [d3], al
exit:
    mov ebx, 0
    mov eax, 1
int 80h
end.