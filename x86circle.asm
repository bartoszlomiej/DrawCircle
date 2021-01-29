global MoveTo
global SetColor
global DrawCircle

section .text

;As i tried to stick to the convention in the 32 bit, hence the switching to the 64 mode was quite easy
;Again I decided to make a SetPixel function as a private one, however, it doesn't change anything, as I stick to
;the convention when getting function arguments. If you would like I could make it public, as it wouldn't really make a difference.

;What can be seen is that now I don't push anything on stack (only rbp), moreover, there are significantly less operations on the main memory. Thanks to grater number of registers it wasn't difficult to deal with greater number of variables

;Here everywhere the rdi is preserved. The byte access to image was used as well as the byte mask preparation.

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
	mov r15b, 0x80
	and cl, 0x07
	shr r15b, cl		;shr needs either imidiate or cl register, which is actually a part of rcx
	mov cl, r15b		;just for the comfortable usage

	cmp DWORD[rdi+24], 1
	jne BlackPixel
	or cl, BYTE[rax]
	mov BYTE[rax], cl
	jmp ReturnVoid
	
BlackPixel:
	not cl			;*pPix &= ~mask;
	and cl, BYTE[rax]		;DWORD[eax]
	mov BYTE[rax], cl

ReturnVoid:
	xor rax, rax		;return void - in this case return 0 
	ret
	
;imgInfo* DrawCircle(imgInfo* pImg, int radius){
DrawCircle:
	;prologue
	push rbp
	
	;due to gdb: rsi radius, rdi *pImg
	;body
	xor rdx, rdx 	; int x = 0, int y = radius => y = rsi
	
	mov r13, rdx ;to preserve acros jmps --- might be used for all SetPixel calls!
	mov r14, rsi ;further the rsi will be x, rdx will be y due to convantion of function calling
	mov r11d, DWORD[rdi+16]	;cX
	mov r12d, DWORD[rdi+20]	;cY
	
	mov rax, rsi
	shl rax, 1
	not rax
	mov rcx, rax
	add rcx, 5
	shl rcx, 2
	mov r8, rcx

	shl rax, 1
	add rax, 5
	mov r9, rax

	mov rax, 12
	mov r10, rax
While:
	mov rax, r13
	mov rsi, r12
	sub rsi, rax 		

	mov rcx, r14
	mov rdx, r11
	sub rdx, rcx		

	;rsi is passed y; rdx is passed x
	;now rsi is x; rdx is y - due to convention
	call SetPixel
	;--------------------------------
	mov rax, r14
	mov rsi, r12
	sub rsi, rax 		;should be passed rax

	mov rcx, r13
	mov rdx, r11
	sub rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	;--------------------------------

	mov rax, r14
	mov rsi, r12
	add rsi, rax 		;should be passed rax

	mov rcx, r13
	mov rdx, r11
	sub rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------

	mov rax, r13
	mov rsi, r12
	add rsi, rax 		;should be passed rax

	mov rcx, r14
	mov rdx, r11
	sub rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------
	mov rax, r13
	mov rsi, r12
	sub rsi, rax 		;should be passed rax

	mov rcx, r14
	mov rdx, r11
	add rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------
	mov rax, r14
	mov rsi, r12
	sub rsi, rax 		;should be passed rax

	mov rcx, r13
	mov rdx, r11
	add rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------
	mov rax, r14
	mov rsi, r12
	add rsi, rax 		;should be passed rax

	mov rcx, r13
	mov rdx, r11
	add rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------
	mov rax, r13
	mov rsi, r12
	add rsi, rax 		;should be passed rax

	mov rcx, r14
	mov rdx, r11
	add rdx, rcx		;should be passed rcx

	;rsi is passed y; rdx is passed x
	call SetPixel
	
	;--------------------------------	
	cmp r9, 0
	jle Else

	add r9, r8		;d += dltA
	dec r14
	inc r13
	add r8, 16 		;dltA += 4*4;
	add r10, 8		;dltB += 2*4;
	jmp Ending

Else:
	add r9, r10		;d += dltB
	inc r13
	add r8, 8		;dltA += 2*4;
	add r10, 8		;dltB += 2*4;
	
Ending:
	cmp r13, r14
	jle While
	mov rax, rdi		;QWORD[rbp+8]
	pop rbp
	ret
