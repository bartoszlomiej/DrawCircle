global MoveTo
global SetColor
global DrawCircle
;extern SetPixel

section .text

;As i tried to stick to the convention in the 32 bit, hence the switching to the 64 mode was quite easy

;It was decided to made the SetPixel a "private" function due to minimize the number of calls to the memory stack.
;The major advantage of this solution over the prior solution is exactly 6 * 8 = 48 calls to the stack less with
;each iteration only in the DrawCircle function! Assuming that the number of calls in the SetPixel was greater then
;it is now (as there were 3 parameters read, and there was saving of the *pPix, and pop of the rbp, hence it is
;assumed that all numbers of calls to the stack had to be greater then 10), however, it might all depend on the
;optimization level on the compiler, I might be wrong.

;The previous solution can be seen in the commits on my github account:
;https://github.com/bartoszlomiej/DrawCircle	
	
;imgInfo* MoveTo(imgInfo* pImg, int x, int y)
MoveTo:
	;prologue
	push rbp
	mov rbp, rsp

	;due to gdb: edx stores 0x100 (y), esi 0x100(x), rdi *pImg
	
	;body
	mov r8, rdi
	mov r9, rsi
	mov r10, rdx
	cmp rsi, 0		;if (x >= 0 && x < pImg->width)
	jl Epilogue
	cmp esi, DWORD[rdi]	
	jge Epilogue

	mov DWORD[rdi+16], esi	;pInfo->cX = x
CheckY:
	cmp rdx, 0		;if (y >= 0 && y < pImg->height)
	jl Epilogue
	cmp edx, DWORD[rdi+4]
	jge Epilogue
	
	mov r11d, edx

	mov DWORD[rdi+20], edx	;pInfo->cY = y
Epilogue:
	;epilogue
	mov rax, rdi
	pop rbp
	ret

;imgInfo* SetColor(imgInfo* pImg, int col){
SetColor:
	;prologue
	push rbp
	mov rbp, rsp
	
	;body
	cmp rsi, 0
	jne ChangeColor;move if not equal | rdi = rdi + 20 = pImg->col
	mov DWORD[rdi+24], 0	
	
	;epilogue
	mov rax, rdi		;QWORD[rbp+16]
	pop rbp			;return pImg
	ret
ChangeColor:
	mov DWORD[rdi+24], 1
	;epilogue
	mov rax, rdi		;QWORD[rbp+8]
	pop rbp			;return pImg
	ret
	
;void SetPixel(imgInfo* pImg, int x, int y){
SetPixel:
;	push ebp
;	mov ebp, esp
	;mov rdi, QWORD[rbp+16]
	;rdi is imgInfo*pImg
	;rsi is int x
	;rdx is int y

	;if (x < 0 || x >= pImg->width || y < 0 || y >= pImg->height)
	cmp rsi, 0		;cpm rdx, 0
	jl ReturnVoid
	cmp esi, DWORD[rdi]	;cmp x, pImg->width
	jge ReturnVoid
	cmp rdx, 0
	jl ReturnVoid
	cmp edx, DWORD[rdi+4]	;cmp y, pImg->height
	jge ReturnVoid

	;unsigned char *pPix = pImg->pImg + (((pImg->width + 31) >> 5) << 2) * y + (x >> 3);
	mov eax, DWORD[rdi]
	add eax, 31
	shr eax, 5
	shl eax, 2
	imul eax, edx		
	mov ecx, esi		;so as to perform x >> 3
	shr ecx, 3
	add eax, ecx
	add rax, QWORD[rdi+8]

	;unsigned char mask = 0x80 >> (x & 0x07);
	mov rcx, rsi
	mov r15, 0x80
	and rcx, 0x07
	shr r15, cl		;shr needs either imidiate or cl register, which is actually a part of rcx
	mov rcx, r15		;just for the comfortable usage
	
;	mov rdi, QWORD[rbp+16]

	cmp DWORD[rdi+24], 1
	jne BlackPixel
	or ecx, DWORD[rax]
;	or ecx, DWORD[eax]	;*pPix |= mask;
	mov DWORD[rax], ecx
	jmp ReturnVoid
	
BlackPixel:
	not ecx			;*pPix &= ~mask;
	and ecx, DWORD[rax]		;DWORD[eax]
	mov DWORD[rax], ecx

ReturnVoid:
	xor rax, rax		;return void - in this case return 0 
	ret
	
;imgInfo* DrawCircle(imgInfo* pImg, int radius){
DrawCircle:
	;prologue
	push rbp
	;	mov rbp, rsp	
	;	mov rdi, QWORD [rbp+16] 	;rdi - is the address of *pImg
	;	mov rsi, QWORD [rbp+24] ; rsi - is int radius
	
	;due to gdb: rsi radius, rdi *pImg
	;body
	xor rdx, rdx 		; int x = 0, int y = radius => y = rsi

	mov r13, rdx ;to preserve acros jmps --- might be used for all SetPixel calls!
	mov r14, rsi
	
	mov rax, rsi
	shl rax, 1
	not rax
	mov rcx, rax
	add rcx, 5
	shl rcx, 2
	mov r8, rcx
;	push rcx		;dltA is r8

	shl rax, 1
	add rax, 5
	mov r9, rax
;	push rax		;d is r9

	mov rax, 12
	mov r10, rax
	;	push rax		;dltB is r10
	mov r11, QWORD[rdi+16]	;cX
	mov r12, QWORD[rdi+20]	;cY
While:
;	mov rdi, QWORD[rbp+16]


;	push rdx
	;	push rsi 		;to preserve acros jmps --- might be used for all SetPixel calls!

	;mov rdi, rax
	mov rax, r13
	mov rsi, r11
	sub rsi, rax 		

	mov rcx, r14
	mov rdx, r12
	sub rdx, rcx		

	;rsi is passed y; rdx is passed x
	;now rsi is x; rdx is y - due to convention
	call SetPixel
	;--------------------------------
;	mov rdi, QWORD[rbp+16]
;	mov rax, QWORD[rdi+24]	;cX
	;	mov rcx, QWORD[rdi+32]	;cY
	
;	mov rdx, QWORD[rbp-40]
;	mov rsi, QWORD[rbp-32]
	;rdx is y
	;rsi is x
;	mov rsi, r11
;	mov rdx, r12
	
;	mov rdi, rax

	mov rax, r14
	mov rsi, r12
	sub rsi, rax 		;should be passed rax
;	mov rsi, rax

	mov rcx, r13
	mov rdx, r11
	sub rdx, rcx		;should be passed rcx
;	mov rdx, rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	
;	pop rsi			;reading the x and y
;	pop rdx

;	mov rax, QWORD[rbp-16]	;d
	cmp r9, 0
	jle Else

;	mov rcx, QWORD[rbp-8] 	;dltA
	add r9, r8
;	mov QWORD[rbp-16], rax 	;d += dltA
	dec r14
	inc r13
	add r8, 16 		;dltA += 4*4;
;	mov QWORD[rbp-8], rcx
;	mov rcx, QWORD[rbp-24]	;dltB
	add r10, 8		;dltB += 2*4;
;	mov QWORD[rbp-24], rcx
	jmp Ending

Else:
;	mov rcx, QWORD[rbp-24]	;dltB
	add r9, r10
;	mov QWORD[rbp-16], rax 	;d += dltB
	inc r13
;	mov rax, QWORD[rbp-8]
	add r8, 8		;dltA += 2*4;
;	mov QWORD[rbp-8], rax
	add r10, 8		;dltB += 2*4;
;	mov QWORD[rbp-24], rcx
	
Ending:
	cmp r13, r14
	jle While
	mov rax, rdi		;QWORD[rbp+8]
;	pop rdi			;just to clean the stack
;	pop rdi
;	pop rdi
	pop rbp
	ret
