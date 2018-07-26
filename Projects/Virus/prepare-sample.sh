cp ../sample.asm .

nasm -g -f elf32 sample.asm
ld -o ./sample -e _start ./sample.o 

rm -rf sample.asm