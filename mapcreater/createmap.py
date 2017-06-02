WIDTH = 6
DEPTH = 4800
ADDRADIX = "HEX"
DATARADIX = "HEX"
chr2gc = {
        '.': 5,
        'x': 2,
        '/': 3,
        '\\': 4
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
        print "%02x;" % chr2gc[map_rc[j][i]]

print "END;"
