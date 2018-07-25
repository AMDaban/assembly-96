nasm -g -f elf32 virus.asm
ld -o ./virus -e v_start ./virus.o 

./virus