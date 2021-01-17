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
	cmp esi, DWORD[edi]	;mr kozuszek code doesn't like this line
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
	mov DWORD[edi+20], 0	;Mr kozuszek code doesn't like this line as well:(
	
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
	
	
DrawCircle:
	;imgInfo* DrawCircle(imgInfo* pImg, int radius){
	;prologue
	push ebp
	mov ebp, esp
	
	mov edi, DWORD [ebp+8] 	;edi - is the address of *pImg
	mov esi, DWORD [ebp+12] ; esi - is int radius -------------------------risky??????

	xor edx, edx 		; int x = 0, int y = radius => y = esi

	mov eax, esi
	shl eax, 1
	not eax
	mov ecx, eax
	add ecx, 5
	shl ecx, 2
	push ecx
;	mov DWORD [ebp-4], ecx	; int dltA is on stack
	shl eax, 1
	add eax, 5
	push eax
;	mov DWORD [ebp-8], eax	;int d in on stack

	mov eax, 12
	push eax
;	mov DWORD [ebp-12], 12	;int dltB in on stack

	
	
;	// draws circle with center in currnet position and given radius
;	int cx = pImg->cX, cy = pImg->cY;
;	int d = 5 - 4 * radius, x = 0, y = radius;
;	int dltA = (-2*radius+5)*4;
;	int dltB = 3*4;
	;------Available registers by now: eax, ecx, edx - int; ax, cx, dx, si, di - short
	;as cx and cy belongs to the bitmap, hence cx, cy [0; 511]
;	add edi, DWORD[edi+8] 	;edi points at the begining of the structure ---Mr kozuszek code doesn't like this..
;	mov eax, WORD[edi+12]	;eax = pImg->cX
;	mov ecx, WORD[edi+16] 	;ecx = pImg->cY
;	xor edx, edx		;edx = int x = 0
;	mov esi, DWORD[ebp+12]	;esi = int y = radius
;	mov si, 0		;si = int x = 0
;	mov di, esi		;di = int y = radius---------------might be useless
	
;	mov dx, di
;	shl dx, 1
;	not dx
;	mov cx, dx
;	add cx, 5
;	shr cx, 2		;cx = int dltA = (-2*radius+5)*4
;	shl dx, 1
;	add dx, 5		;dx = int d = 5 - 4*radius

;	mov ax, 12		;edx = int dltB = 3*4 = 12
While:
	;Available registers by now: esi, eax -----remember to load the result to eax in the end!!
	mov edi, DWORD[ebp+8]
	mov eax, DWORD[edi+12]	;cX
	mov ecx, DWORD[edi+16]	;cY

	push edx
	push esi 		;to preserve acros jmps
	
	mov edi, eax
	sub edi, edx
	push edi

	mov edi, ecx
	sub edi, esi
	push edi

	push DWORD[ebp+8]
	call SetPixel

	pop DWORD[ebp+8]
	pop edi
	pop edi			;-----------------?????????????????????????????????????????

	pop esi
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
	mov DWORD[ebp-8], ecx
	jmp Ending
Else:
	mov ecx, DWORD[ebp-12]	;dltB
	add eax, ecx
	mov DWORD[ebp-8], eax 	;d += dltB
	dec esi
	inc edx
	mov eax, DWORD[ebp-4]
	add eax, 8		;dltA += 2*4;
	mov DWORD[ebp-4], eax
	add ecx, 8		;dltB += 2*4;
	mov DWORD[ebp-8], ecx
	
Ending:
	cmp edx, esi
	jle While
	mov eax, DWORD[ebp+8]
	pop edi
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
