ASMBIN = nasm
CC=gcc

all : asm cc link clean
asm :
	$(ASBIN) nasm -o circle.o -f elf -gdwarf -g -l circle.lst circle.asm
cc :
	$(CC) -m32 -fpack-struct -c -g -O0 advanced.c &> errors.txt
link :
	$(CC) -m32 -g -fpack-struct -o test advanced.o circle.o

clean :
	rm *.o
	rm circle.lst
	rm *~
