#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

//typedef struct imgInfo img;

typedef struct{
	int width, height;
	unsigned char* pImg;
	int cX, cY;
	int col;
} imgInfo;

extern imgInfo *MoveTo(imgInfo* pInfo, int x, int y);
extern imgInfo *SetColor(imgInfo* pInfo, int col);
extern imgInfo *DrawCircle(imgInfo* pInfo, int radius);

void SetPixel(imgInfo* pImg, int x, int y)
{
	unsigned char *pPix = pImg->pImg + (((pImg->width + 31) >> 5) << 2) * y + (x >> 3);
	unsigned char mask = 0x80 >> (x & 0x07);

	if (x < 0 || x >= pImg->width || y < 0 || y >= pImg->height)
		return;

	if (pImg->col)
		*pPix |= mask;
	else
		*pPix &= ~mask;
}

int main(int argc, char* argv[]){
	imgInfo* pInfo;
	pInfo = (imgInfo*) malloc(sizeof(imgInfo));
	pInfo->width = 511;
	pInfo->height = 511;
	pInfo->cX = 255;
	pInfo->cY = 255;
	pInfo->col = 0;

	printf("width: %d; height: %d\n", pInfo->width, pInfo->height);
	pInfo = MoveTo(pInfo, 5, 10);
	//	printf("new width: %d, height: %d\n", &(pInfo->width), (pInfo+1));//one next address space
	printf("new width: %d, height: %d\n", (pInfo->cX), pInfo->cY);//one next address space

	printf("color: %d\n", pInfo->col);
	pInfo = SetColor(pInfo, 1);
	printf("new color: %d\n", pInfo->col);
	return 0;
}
/* void SetPixel(imgInfo* pImg, int x, int y) */
/* { */
/* 	unsigned char *pPix = pImg->pImg + (((pImg->width + 31) >> 5) << 2) * y + (x >> 3); */
/* 	unsigned char mask = 0x80 >> (x & 0x07); */

/* 	if (x < 0 || x >= pImg->width || y < 0 || y >= pImg->height) */
/* 		return; */

/* 	if (pImg->col) */
/* 		*pPix |= mask; */
/* 	else */
/* 		*pPix &= ~mask; */
/* } */
