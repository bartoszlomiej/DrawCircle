ASMBIN = nasm
CC=gcc

all : asm cc link clean
asm :
	$(ASBIN) nasm -o x86circle.o -f elf64 -gdwarf -g -l x86circle.lst x86circle.asm
cc :
	$(CC) -m64 -c -g -O0 advanced.c &> errors.txt
link :
	$(CC) -m64 -g -o test advanced.o x86circle.o

clean :
	rm *.o
	rm x86circle.lst
	rm *~
