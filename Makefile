ASMBIN = nasm
CC=gcc

all : asm cc link clean
asm :
	$(ASBIN) nasm -o x64circle.o -f elf64 -gdwarf -g -l x64circle.lst x64circle.asm
cc :
	$(CC) -m64 -c -g -O0 advanced.c &> errors.txt
link :
	$(CC) -m64 -g -o test advanced.o x64circle.o

clean :
	rm *.o
	rm x64circle.lst
	rm *~
