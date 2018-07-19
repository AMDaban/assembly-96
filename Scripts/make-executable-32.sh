CUR_PATH=`pwd`
FILE_PATH=$CUR_PATH/$1

cd $CUR_PATH/$2

nasm -g -f elf32 $FILE_PATH
ld -m elf_i386 -o ./$3 -e _start ./$3.o 

cd $CUR_PATH