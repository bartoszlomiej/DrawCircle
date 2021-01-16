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
	return 0;
}
