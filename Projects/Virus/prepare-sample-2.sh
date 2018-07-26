cp ../sample.asm ./sample-2.asm

nasm -g -f elf32 sample-2.asm
ld -o ./sample-2 -e _start ./sample-2.o 

rm -rf sample-2.asm