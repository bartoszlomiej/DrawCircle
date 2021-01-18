global MoveTo
global SetColor
global DrawCircle

section .text

;It was decided to made the SetPixel a "private" function due to minimize the number of calls to the memory stack.
;The major advantage of this solution over the prior solution is exactly 6 * 8 = 48 calls to the stack with
;each iteration only in the DrawCircle function! Assuming that the number of calls in the SetPixel was greater then
;it is now (as there were 3 parameters read, and there was saving of the *pPix, and pop of the ebp, hence it is
;assumed that all numbers of calls to the stack had to be greater then 10), however, it might all depend on the
;optimization level on the compiler, I might be wrong.

;The previous solution can be seen in the commits on my github account:
;https://github.com/bartoszlomiej/DrawCircle	
	
;imgInfo* MoveTo(imgInfo* pImg, int x, int y)
MoveTo:
	;prologue
	push ebp
	mov ebp, esp
	mov edi, DWORD [ebp+8]	;edi - is the address of *pImg
	mov esi, DWORD [ebp+12]	;esi - is int x
	mov edx, DWORD [ebp+16]	;edx - is int y
	
	;body
	cmp esi, 0		;if (x >= 0 && x < pImg->width)
	jl Epilogue
	cmp esi, DWORD[edi]	
	jge Epilogue

	mov DWORD[edi+12], esi	;pInfo->cX = x
CheckY:
	cmp edx, 0		;if (y >= 0 && y < pImg->height)
	jl Epilogue
	cmp edx, DWORD[edi+4]
	jge Epilogue

	mov DWORD[edi+16], edx	;pInfo->cY = y
Epilogue:
	;epilogue
	mov eax, DWORD[ebp+8] 	;return pImg
	pop ebp
	ret

;imgInfo* SetColor(imgInfo* pImg, int col){
SetColor:
	;prologue
	push ebp
	mov ebp, esp
	mov edi, DWORD[ebp+8]	;edi is the address of *pImg
	mov esi, DWORD[ebp+12] 	;esi - is int col
	
	;body
	cmp esi, 0
	jne ChangeColor;move if not equal | edi = edi + 20 = pImg->col
	mov DWORD[edi+20], 0	
	
	;epilogue
	mov eax, DWORD[ebp+8]
	pop ebp			;return pImg
	ret
ChangeColor:
	mov DWORD[edi+20], 1
	;epilogue
	mov eax, DWORD[ebp+8]
	pop ebp			;return pImg
	ret
	
;void SetPixel(imgInfo* pImg, int x, int y){
SetPixel:
	mov edi, DWORD[ebp+8]
	;edi is imgInfo*pImg
	;esi is int x
	;edx is int y

	;if (x < 0 || x >= pImg->width || y < 0 || y >= pImg->height)
	cmp edx, 0
	jl ReturnVoid
	cmp edx, DWORD[edi]	;cmp x, pImg->width
	jge ReturnVoid
	cmp esi, 0
	jl ReturnVoid
	cmp esi, DWORD[edi+4]	;cmp y, pImg->height
	jge ReturnVoid

	;unsigned char *pPix = pImg->pImg + (((pImg->width + 31) >> 5) << 2) * y + (x >> 3);
	mov eax, DWORD[edi]
	add eax, 31
	shr eax, 5
	shl eax, 2
	imul eax, esi		
	mov ecx, edx		;so as to perform x >> 3
	shr ecx, 3
	add eax, ecx
	add eax, DWORD[edi+8]

	;unsigned char mask = 0x80 >> (x & 0x07);
	mov ecx, edx
	mov edi, 0x80
	and ecx, 0x07
	shr edi, cl		;shr needs either imidiate or cl register, which is actually a part of ecx
	mov ecx, edi		;just for the comfortable usage
	
	mov edi, DWORD[ebp+8]

	cmp DWORD[edi+20], 1
	jne BlackPixel
	or ecx, DWORD[eax]	;*pPix |= mask;
	mov DWORD[eax], ecx
	jmp ReturnVoid
	
BlackPixel:
	not ecx			;*pPix &= ~mask;
	and ecx, DWORD[eax]
	mov DWORD[eax], ecx

ReturnVoid:
	xor eax, eax		;return void - in this case return 0 
	ret
	
;imgInfo* DrawCircle(imgInfo* pImg, int radius){
DrawCircle:
	;prologue
	push ebp
	mov ebp, esp	
	mov edi, DWORD [ebp+8] 	;edi - is the address of *pImg
	mov esi, DWORD [ebp+12] ; esi - is int radius
	
	;body
	xor edx, edx 		; int x = 0, int y = radius => y = esi

	mov eax, esi
	shl eax, 1
	not eax
	mov ecx, eax
	add ecx, 5
	shl ecx, 2
	push ecx		;push dltA on stack on the address ebp-4

	shl eax, 1
	add eax, 5
	push eax		;push d on stack on the address ebp-8

	mov eax, 12
	push eax		;push dltB on stack on the address ebp-12
While:
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	push edx
	push esi 		;to preserve acros jmps --- might be used for all SetPixel calls!

	mov edi, eax
	sub edi, edx 		;should be passed eax
	mov edx, edi

	mov edi, ecx
	sub edi, esi		;should be passed ecx
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-20]
	mov esi, DWORD[ebp-16]

	mov edi, eax
	sub edi, edx 		
	mov edx, edi

	mov edi, ecx
	sub edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-16]
	mov esi, DWORD[ebp-20]

	mov edi, eax
	add edi, edx 		
	mov edx, edi

	mov edi, ecx
	sub edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-20]
	mov esi, DWORD[ebp-16]

	mov edi, eax
	add edi, edx 		
	mov edx, edi

	mov edi, ecx
	sub edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-16]
	mov esi, DWORD[ebp-20]

	mov edi, eax
	sub edi, edx 		
	mov edx, edi

	mov edi, ecx
	add edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-20]
	mov esi, DWORD[ebp-16]

	mov edi, eax
	sub edi, edx 		
	mov edx, edi

	mov edi, ecx
	add edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-16]
	mov esi, DWORD[ebp-20]

	mov edi, eax
	add edi, edx 		
	mov edx, edi

	mov edi, ecx
	add edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	;--------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	mov edx, DWORD[ebp-20]
	mov esi, DWORD[ebp-16]

	mov edi, eax
	add edi, edx 		
	mov edx, edi

	mov edi, ecx
	add edi, esi		
	mov esi, edi

	;esi is passed y; edx is passed x
	call SetPixel
	;--------------------------------
	
	pop esi			;reading the x and y
	pop edx

	mov eax, DWORD[ebp-8]	;d
	cmp eax, 0
	jle Else

	mov ecx, DWORD[ebp-4] 	;dltA
	add eax, ecx
	mov DWORD[ebp-8], eax 	;d += dltA
	dec esi
	inc edx
	add ecx, 16 		;dltA += 4*4;
	mov DWORD[ebp-4], ecx
	mov ecx, DWORD[ebp-12]	;dltB
	add ecx, 8		;dltB += 2*4;
	mov DWORD[ebp-12], ecx
	jmp Ending

Else:
	mov ecx, DWORD[ebp-12]	;dltB
	add eax, ecx
	mov DWORD[ebp-8], eax 	;d += dltB
	inc edx
	mov eax, DWORD[ebp-4]
	add eax, 8		;dltA += 2*4;
	mov DWORD[ebp-4], eax
	add ecx, 8		;dltB += 2*4;
	mov DWORD[ebp-12], ecx
	
Ending:
	cmp edx, esi
	jle While
	mov eax, DWORD[ebp+8]
	pop edi			;just to clean the stack
	pop edi
	pop edi
	pop ebp
	ret
