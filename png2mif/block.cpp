/*
 * Usage: block > block.mif
 *   其中可执行文件block放到和block0.png .. blockK.png同一个目录下
 *   (K = NUM_USED - 1)
 *   之后复制player.mif到res文件夹中
 *
 * Config
 *  NUM_USED: 读入文件是p0.png .. pK.png
 *      e.g. NUM_USED = 60, 那么block会读入 p0.png .. p59.png
 *  fileNamePattern: 输入文件名的格式, 必须是接受一个%d的format string (C)
 *      e.g. 改成"pic%d.png", 那么输入文件是 pic0.png pic1.png ...
 *  defaultFileName: 对于 NUM_USED <= J < 64, 第J种方格是此文件指定的内容
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
