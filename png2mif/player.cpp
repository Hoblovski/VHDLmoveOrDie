/*
 * Usage: player > player.mif
 *   其中可执行文件player放到和player1.png .. player4.png同一个目录下
 *   之后复制player.mif到res文件夹中
 */
#include <lodepng.h>
#include <cstdio>
#include <vector>
#include <string>
#include <cassert>
using namespace std;

unsigned lodepng_decode_file(unsigned char** out, unsigned* w, unsigned* h,
                             const char* filename,
                             LodePNGColorType colortype, unsigned bitdepth);

unsigned char* img;
unsigned W, H;

const int WIDTH = 9; // RGB
const int DEPTH = 4096; // 4 players (first 2 bit); 3 x 3 size (then 4 bit); grid 8 x 8 <= 4096 (last 6 bit)
const char header[] = "WIDTH=%d;\nDEPTH=%d;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n";
const char foutPath[] = "out.mif";
const int kNPlayers = 4;
char fileName[20];
char fileNameFormat[] = "player%d.png";

int main() {
    printf(header, WIDTH, DEPTH);
    int totK = 0;
    for (int i = 1; i <= kNPlayers; i++) {
        sprintf(fileName, fileNameFormat, i);
        assert(lodepng_decode_file(&img, &W, &H, fileName, LCT_RGB, 8) == 0);
        assert ((W == 3 * 8) && (H == 3 * 8));
        for (int gn = 0; gn < 3 * 3; gn++) {
            int x0 = 8 * (gn / 3);
            int y0 = 8 * (gn % 3);
            for (int x = 0; x < 8; x++)
                for (int y = 0; y < 8; y++) {
                    int xx = x + x0;
                    int yy = y + y0;
                    int k = xx * 3 + yy * 8*3 * 3;
                    printf("%03x: %03x;\n", totK++,
                            (((img[k]>>5)&7)<<6) |
                            (((img[k+1]>>5)&7)<<3) |
                            (((img[k+2]>>5)&7)));
                }
        }
        while (totK < 1024 * i)
            printf("%03x: %03x;\n", totK++, 0);
        printf("\n");
    }
    printf("END;\n");
    return 0;
}
