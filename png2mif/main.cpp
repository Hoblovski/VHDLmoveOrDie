#include <lodepng.h>
#include <cstdio>

unsigned lodepng_decode_file(unsigned char** out, unsigned* w, unsigned* h,
                             const char* filename,
                             LodePNGColorType colortype, unsigned bitdepth);

unsigned char* img;
unsigned W, H;

const char headerFormat[] = "WIDTH=1;\nDEPTH=16384;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n";
const char foutPath[] = "out.mif";

int main() {
    lodepng_decode_file(&img, &W, &H,
            "test.png",
            LCT_GREY, 8);
    FILE* fout = fopen(foutPath, "w");
    for (int i = 0; i < W; i++)
        for (int j = 0; j < H; j++)
            ;// TODO
    return 0;
}
