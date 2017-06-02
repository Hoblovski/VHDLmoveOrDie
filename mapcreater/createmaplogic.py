WIDTH = 1
DEPTH = 4800
ADDRADIX = "HEX"
DATARADIX = "HEX"
chr2blk = {
        '.': 0,
        'x': 1,
        '/': 1,
        '\\': 1
}


with open("map.txt", "r") as f:
    map_rc = [l.strip() for l in f.readlines()]
# row -> y; column -> x

print "WIDTH=%d;" % WIDTH
print "DEPTH=%d;" % DEPTH
print "ADDRESS_RADIX=%s;" % ADDRADIX
print "DATA_RADIX=%s;" % DATARADIX
print "\nCONTENT_BEGIN"

for i in range(80):
    for j in range(60):
        k = i * 60 + j
        print "%04x:" % k,
        print "%x;" % chr2blk[map_rc[j][i]]

print "END;"

