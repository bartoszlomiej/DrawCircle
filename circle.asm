global MoveTo
global SetColor

section .text
;imgInfo* MoveTo(imgInfo* pImg, int x, int y)
MoveTo:
	;prologue
	push ebp
	mov ebp, esp
	mov edi, DWORD [ebp+8]	;edi - is the address of *pImg
	mov esi, DWORD [ebp+12]	;esi - is int x
	mov edx, DWORD [ebp+16]	;edx - is int y
	
	;body
	add edi, DWORD[edi+8] 	;edi = int width
	
	cmp esi, 0		;if (x >= 0 && x < pImg->width)
	jl CheckY
	cmp esi, DWORD[edi]
	jge CheckY

	mov DWORD[edi+12], esi	;pInfo->width = x
CheckY:
	cmp edx, 0		;if (y >= 0 && y < pImg->height)
	jl Epilogue
	cmp edx, edi
	jge Epilogue

	mov DWORD[edi+16], edx	;pInfo->height = y
Epilogue:
	;epilogue
	mov eax, DWORD[ebp+8] 	;return pImg
	pop ebp
	ret

SetColor:
	;imgInfo* SetColor(imgInfo* pImg, int col){
;	pImg->col = col != 0;
;	return pImg;
	;}
	;prologue
	push ebp
	mov ebp, esp
	mov edi, DWORD[ebp+8]	;edi is the address of *pImg
	mov esi, DWORD[ebp+12] 	;esi - is int col
	
	;body
	add edi, DWORD[edi+8]	; edi = edi + addr_height ->first element of the pImg
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
