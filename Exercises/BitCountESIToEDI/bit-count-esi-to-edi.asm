;_bit_count_esi_to_edi counts the number of bits with 1 value between esi and edi and store it in eax

section .data
    byte_array db 0xff, 0xef, 0xff, 0xef, 0x1, 0xcd
    byte_array_length equ $ - byte_array

    ;target bytes

section .text
    global _start
_start:

    mov esi, byte_array     ;set esi and edi
    lea edi, [esi + byte_array_length - 1]

    call _bit_count_esi_to_edi 

exit:
    mov ebx, 0
    mov eax, 1
    int 80h

;---------------------------

_bit_count_esi_to_edi:      ;_bit_count_esi_to_edi counts the number of bits with 1 value between esi and edi and store it in eax

    mov r11d, esi           ;store previous values

    xor r12, r12            ;clear r12, answer will be in eax

    cmp esi, edi            ;jump out if esi > edi
    jg main_return

    first_loop:

        xor rax, rax
        mov al, [esi]       ;load one byte in al

        call _bit_count     ;compute number of 1 bits in ax(in this case al)

        add r12b, bl

        inc esi

        cmp esi, edi        ;jump out if esi > edi
        jg main_return

    jmp first_loop

    main_return:

    mov eax, r12d

    mov esi, r11d           ;restore previous values

    ret

;---------------------------

_bit_count:                 ;_bit_count counts the number of bits with 1 value in ax and store it in bx

    mov r8, rax             ;store previous values
    mov r9, rcx
    mov r10, rdx
    
    xor rbx, rbx            ;clear rbx, result will be in bx
    xor rcx, rcx
    xor rdx, rdx

    main_loop:

        bsf cx, ax          ;find least significant 1 in ax
        jz return           ;if no 1 found, goto end
        btc ax, cx          ;clear the used bit
        inc bx

    jmp main_loop

    return:
    mov rax, r8             ;restore previous values
    mov rcx, r9
    mov rdx, r10

    ret

;---------------------------