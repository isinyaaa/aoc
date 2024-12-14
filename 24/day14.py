from pathlib import Path

size = 103
rowsize = 101


def stoc(a, b):
    return int(a) + int(b) * 1j


data = [
    tuple(stoc(*v.split(" ")[0].split(",")) for v in ls.split("=")[1:])
    for ls in Path("day14.in").read_text().splitlines()
]


def draw(rbs):
    pic = [
        "".join(["#" if x + y * 1j in rbs else "." for x in range(rowsize)])
        for y in range(size)
    ]
    for p in pic:
        print(p)


qs = [0, 0, 0, 0]
rbs = {}
for r, (op, d) in enumerate(data):
    fp = op + d * 100
    fpm = (int(fp.real) % rowsize) + (int(fp.imag) % size) * 1j
    rbs[fpm] = str(r)
    fx, fy = (int(fpm.real) - rowsize // 2), (int(fpm.imag) - size // 2)
    for i, (qx, qy) in enumerate(
        [
            (-1, 1),
            (1, 1),
            (1, -1),
            (-1, -1),
        ]
    ):
        qs[i] += qx * fx > 0 and qy * fy > 0

# draw(rbs)

pd = 1
for q in qs:
    pd *= q

print(pd)

pos, vs = zip(*data)
mcount = len(pos)
pos = list(pos)

for s in range(1, 10000):
    rbs = {}
    for r, d in enumerate(vs):
        fp = pos[r] + d
        fpm = (int(fp.real) % rowsize) + (int(fp.imag) % size) * 1j
        pos[r] = fpm
        rbs[fpm] = str(r)

    macs = {p: {p} for p in rbs}

    # dfs + union find
    for p, v in rbs.items():
        for d in (1, -1, 1j, -1j):
            n = p + d
            if (rv := rbs.get(n)) is not None and rv != v:
                macs[p] |= macs[n]
                for r in macs[n]:
                    macs[r] = macs[p]

    if len({tuple(m) for m in macs.values()}) < mcount // 2:
        print()
        print("==============", s, "===============")
        draw(rbs)
        print()
        break
