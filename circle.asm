extern SetPixel

global MoveTo
global SetColor
global DrawCircle

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

;SetPixel:
;	push ebp
;	mov ebp, esp
;	call
	
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

	;reasonable ---- pass the arguments in registers instead of pushing them on the stack
	;however, how to do this?
	
	mov edi, eax
	sub edi, edx
	push edi

	mov edi, ecx
	sub edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters?
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-20]
	mov edi, eax
	sub edi, edx
	push edi

	mov esi, DWORD[ebp-16]
	mov edi, ecx
	sub edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-20]
	mov edi, eax
	add edi, edx
	push edi

	mov esi, DWORD[ebp-16]
	mov edi, ecx
	add edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-16]
	mov edi, eax
	add edi, edx
	push edi

	mov esi, DWORD[ebp-20]
	mov edi, ecx
	add edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-16]
	mov edi, eax
	add edi, edx
	push edi

	mov esi, DWORD[ebp-20]
	mov edi, ecx
	sub edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-20]
	mov edi, eax
	add edi, edx
	push edi

	mov esi, DWORD[ebp-16]
	mov edi, ecx
	sub edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------		
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-20]
	mov edi, eax
	sub edi, edx
	push edi

	mov esi, DWORD[ebp-16]
	mov edi, ecx
	add edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
	;------------------------------------------
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]
	mov ecx, DWORD[edi+16]
	
	mov edx, DWORD[ebp-16]
	mov edi, eax
	sub edi, edx
	push edi

	mov esi, DWORD[ebp-20]
	mov edi, ecx
	add edi, esi
	push edi

	push DWORD[ebp+8]	;edi, esi, edx -- can be used to pass parameters!
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;just to clean the stack
	;------------------------------------------
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
;	dec esi
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
;	while (x <= y)
;	{
;		// 8 symmetric pixels
;		SetPixel(pImg, cx-x, cy-y);
;		SetPixel(pImg, cx-x, cy+y);
;		SetPixel(pImg, cx+x, cy-y);
;		SetPixel(pImg, cx+x, cy+y);
;		SetPixel(pImg, cx-y, cy-x);
;		SetPixel(pImg, cx-y, cy+x);
;		SetPixel(pImg, cx+y, cy-x);
;		SetPixel(pImg, cx+y, cy+x);
;		if (d > 0)
;		{
;			d += dltA;
;			y--;
;			x++;
;			dltA += 4*4;
;			dltB += 2*4;
;		}
;		else
;		{
;			d += dltB;
;			x++;
;			dltA += 2*4;
;			dltB += 2*4;
;		}
;	}
;	return pImg;
;}				
