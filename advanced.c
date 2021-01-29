#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <math.h>

typedef struct{
	int width, height;
	unsigned char* pImg;
	int cX, cY;
	int col;
} imgInfo;

extern imgInfo *MoveTo(imgInfo* pInfo, int x, int y);
extern imgInfo *SetColor(imgInfo* pInfo, int col);
extern imgInfo *DrawCircle(imgInfo* pInfo, int radius);

#pragma pack(push, 1)
typedef struct
{
  uint16_t bfType;
  uint32_t  bfSize; 
  uint16_t bfReserved1; 
  uint16_t bfReserved2; 
  uint32_t  bfOffBits; 
  uint32_t  biSize; 
  int32_t  biWidth; 
  int32_t  biHeight; 
  int16_t biPlanes; 
  int16_t biBitCount; 
  uint32_t  biCompression; 
  uint32_t  biSizeImage; 
  int32_t biXPelsPerMeter; 
  int32_t biYPelsPerMeter; 
  uint32_t  biClrUsed; 
  uint32_t  biClrImportant;
  uint32_t  RGBQuad_0;
  uint32_t  RGBQuad_1;
} bmpHdr;
#pragma pack(pop)

void* freeResources(FILE* pFile, void* pFirst, void* pSnd)
{
	if (pFile != 0)
		fclose(pFile);
	if (pFirst != 0)
		free(pFirst);
	if (pSnd !=0)
		free(pSnd);
	return 0;
}

imgInfo* readBMP(const char* fname)
{
	imgInfo* pInfo = 0;
	FILE* fbmp = 0;
	bmpHdr bmpHead;
	int lineBytes, y;
	unsigned long imageSize = 0;
	unsigned char* ptr;

	pInfo = 0;
	fbmp = fopen(fname, "rb");
	if (fbmp == 0)
		return 0;

	fread((void *) &bmpHead, sizeof(bmpHead), 1, fbmp);
	// parê sprawdzeñ
	if (bmpHead.bfType != 0x4D42 || bmpHead.biPlanes != 1 ||
		bmpHead.biBitCount != 1 || bmpHead.biClrUsed != 2 ||
		(pInfo = (imgInfo *) malloc(sizeof(imgInfo))) == 0)
		return (imgInfo*) freeResources(fbmp, pInfo->pImg, pInfo);

	pInfo->width = bmpHead.biWidth;
	pInfo->height = bmpHead.biHeight;
	imageSize = (((pInfo->width + 31) >> 5) << 2) * pInfo->height;

	if ((pInfo->pImg = (unsigned char*) malloc(imageSize)) == 0)
		return (imgInfo*) freeResources(fbmp, pInfo->pImg, pInfo);

	// process height (it can be negative)
	ptr = pInfo->pImg;
	lineBytes = ((pInfo->width + 31) >> 5) << 2; // line size in bytes
	if (pInfo->height > 0)
	{
		// "upside down", bottom of the image first
		ptr += lineBytes * (pInfo->height - 1);
		lineBytes = -lineBytes;
	}
	else
		pInfo->height = -pInfo->height;

	// reading image
	// moving to the proper position in the file
	if (fseek(fbmp, bmpHead.bfOffBits, SEEK_SET) != 0)
		return (imgInfo*) freeResources(fbmp, pInfo->pImg, pInfo);

	for (y=0; y<pInfo->height; ++y)
	{
		fread(ptr, 1, abs(lineBytes), fbmp);
		ptr += lineBytes;
	}
	fclose(fbmp);
	return pInfo;
}

int saveBMP(const imgInfo* pInfo, const char* fname)
{
	int lineBytes = ((pInfo->width + 31) >> 5)<<2;
	bmpHdr bmpHead = 
	{
	0x4D42,				// unsigned short bfType; 
	sizeof(bmpHdr),		// unsigned long  bfSize; 
	0, 0,				// unsigned short bfReserved1, bfReserved2; 
	sizeof(bmpHdr),		// unsigned long  bfOffBits; 
	40,					// unsigned long  biSize; 
	pInfo->width,		// long  biWidth; 
	pInfo->height,		// long  biHeight; 
	1,					// short biPlanes; 
	1,					// short biBitCount; 
	0,					// unsigned long  biCompression; 
	lineBytes * pInfo->height,	// unsigned long  biSizeImage; 
	11811,				// long biXPelsPerMeter; = 300 dpi
	11811,				// long biYPelsPerMeter; 
	2,					// unsigned long  biClrUsed; 
	0,					// unsigned long  biClrImportant;
	0x00000000,			// unsigned long  RGBQuad_0;
	0x00FFFFFF			// unsigned long  RGBQuad_1;
	};

	FILE * fbmp;
	unsigned char *ptr;
	int y;

	if ((fbmp = fopen(fname, "wb")) == 0)
		return -1;
	if (fwrite(&bmpHead, sizeof(bmpHdr), 1, fbmp) != 1)
	{
		fclose(fbmp);
		return -2;
	}

	ptr = pInfo->pImg + lineBytes * (pInfo->height - 1);
	for (y=pInfo->height; y > 0; --y, ptr -= lineBytes)
		if (fwrite(ptr, sizeof(unsigned char), lineBytes, fbmp) != lineBytes)
		{
			fclose(fbmp);
			return -3;
		}
	fclose(fbmp);
	return 0;
}

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

/*
imgInfo* DrawCircle(imgInfo* pImg, int radius)
{
	// draws circle with center in currnet position and given radius
	int cx = pImg->cX, cy = pImg->cY;
	int d = 5 - 4 * radius, x = 0, y = radius;
	int dltA = (-2*radius+5)*4;
	int dltB = 3*4;

	while (x <= y)
	{
		// 8 symmetric pixels
		SetPixel(pImg, cx-x, cy-y);
		SetPixel(pImg, cx-x, cy+y);
		SetPixel(pImg, cx+x, cy-y);
		SetPixel(pImg, cx+x, cy+y);
		SetPixel(pImg, cx-y, cy-x);
		SetPixel(pImg, cx-y, cy+x);
		SetPixel(pImg, cx+y, cy-x);
		SetPixel(pImg, cx+y, cy+x);
		if (d > 0)
		{
			d += dltA;
			y--;
			x++;
			dltA += 4*4;
			dltB += 2*4;
		}
		else
		{
			d += dltB;
			x++;
			dltA += 2*4;
			dltB += 2*4;
		}
	}
	return pImg;
}
*/
/****************************************************************************************/
imgInfo* InitScreen (int w, int h)
{
	imgInfo *pImg;
	if ( (pImg = (imgInfo *) malloc(sizeof(imgInfo))) == 0)
		return 0;
	pImg->height = h;
	pImg->width = w;
	pImg->pImg = (unsigned char*) malloc((((w + 31) >> 5) << 2) * h);
	if (pImg->pImg == 0)
	{
		free(pImg);
		return 0;
	}
	memset(pImg->pImg, 0xFF, (((w + 31) >> 5) << 2) * h);
	pImg->cX = 0;
	pImg->cY = 0;
	pImg->col = 0;
	return pImg;
}

void FreeScreen(imgInfo* pInfo)
{
	if (pInfo && pInfo->pImg)
		free(pInfo->pImg);
	if (pInfo)
		free(pInfo);
}

/****************************************************************************************/

int main(int argc, char* argv[])
{
	imgInfo* pInfo;
	int i, j;
	if (sizeof(bmpHdr) != 62)
	{
		printf("Change compilation options so as bmpHdr struct size is 62 bytes.\n");
		return 1;
	}
	/*
	if ((pInfo = InitScreen (512, 512)) == 0)
		return 2;

	SetColor(pInfo, 0);
	for (i=0; i<256; ++i)
	{
		for (j = 256; j < 512; ++j)
		{
			SetPixel(pInfo, j, i);
			SetPixel(pInfo, i, j);
		}
	}
	saveBMP(pInfo, "blank.bmp");
	*/

	pInfo = readBMP("blank.bmp");
	MoveTo(pInfo, 256, 256);
	int a = 10;
	printf("int: %d\n struct: %d\n", sizeof(a), sizeof(pInfo));
	printf("Moved to: %d, %d", pInfo->cX, pInfo->cY);

	for (i=3; i < 256; i+=3){
	  SetColor(pInfo, i & 1);
	  DrawCircle(pInfo, i);
	}

	saveBMP(pInfo, "result.bmp");
	FreeScreen(pInfo);
	return 0;
}

