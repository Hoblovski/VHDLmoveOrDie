/*
 * Usage: block > block.mif
 *   ���п�ִ���ļ�block�ŵ���block0.png .. blockK.pngͬһ��Ŀ¼��
 *   (K = NUM_USED - 1)
 *   ֮����player.mif��res�ļ�����
 *
 * Config
 *  NUM_USED: �����ļ���p0.png .. pK.png
 *      e.g. NUM_USED = 60, ��ôblock����� p0.png .. p59.png
 *  fileNamePattern: �����ļ����ĸ�ʽ, �����ǽ���һ��%d��format string (C)
 *      e.g. �ĳ�"pic%d.png", ��ô�����ļ��� pic0.png pic1.png ...
 *  defaultFileName: ���� NUM_USED <= J < 64, ��J�ַ����Ǵ��ļ�ָ��������
 */
const int NUM_USED = 6;
const char fileNamePattern = "p%d.png";
const char defaultFileName = "p0.png";

#include <lodepng.h>
#include <stdio.h>
#include <assert.h>

unsigned lodepng_decode_file(unsigned char** out, unsigned* w, unsigned* h,
                             const char* filename,
                             LodePNGColorType colortype, unsigned bitdepth);

unsigned char* img;
unsigned W, H;

const int WIDTH = 9;        // RGB 3 x 3
const int DEPTH = 64 * 64;  // 64 blocks; each 8 x 8
const char HEADER[] = "WIDTH=%d;\nDEPTH=%d;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n";

char fileName[20];

int main() {
    assert(NUM_USED <= 64);
    printf(HEADER, WIDTH, DEPTH);
    int totK = 0;
    for (int i = 0; i < NUM_USED; i++) {
        sprintf(fileName, fileNamePattern, i);
        assert(lodepng_decode_file(&img, &W, &H, fN.c_str(), LCT_RGB, 8) == 0);
        assert ((W == 8) && (H == 8));
        for (int x = 0; x < 8; x++)
            for (int y = 0; y < 8; y++) {
                int k = x * 3 + y * 8 * 3;
                printf("%03x: %03x;\n", totK++,
                        (((img[k]>>5)&7)<<6) |
                        (((img[k+1]>>5)&7)<<3) |
                        (((img[k+2]>>5)&7)));
            }
        printf("\n");
    }

    assert(lodepng_decode_file(&img, &W, &H, defaultFileName, LCT_RGB, 8) == 0);
    assert ((W == 8) && (H == 8));
    for (int i = NUM_USED; i < 64; i++) {
        for (int x = 0; x < 8; x++)
            for (int y = 0; y < 8; y++) {
                int k = x * 3 + y * 8 * 3;
                printf("%03x: %03x;\n", totK++,
                        (((img[k]>>5)&7)<<6) |
                        (((img[k+1]>>5)&7)<<3) |
                        (((img[k+2]>>5)&7)));
            }
        printf("\n");
    }

    printf("END;\n");
    return 0;
}
