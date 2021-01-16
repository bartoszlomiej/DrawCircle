ASMBIN = nasm
CC=gcc

all : asm cc link clean
asm :
	$(ASBIN) nasm -o circle.o -f elf -g -l circle.lst circle.asm
cc :
	$(CC) -m32 -c -g -O0 main.c &> errors.txt
link :
	$(CC) -m32 -g -o test main.o circle.o

clean :
	rm *.o
	rm circle.lst
	rm *~
