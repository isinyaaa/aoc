from pathlib import Path

disk = [int(c) for c in Path("day9.in").read_text().strip()]

blocks, gaps = disk[2::2], disk[1::2]

dmap = [
    i // 2 + 1 if i % 2 != 0 else 0
    for i, c in enumerate(disk[1::])
    for _ in range(int(c))
]
disk = disk[::-1]

maxid = len(blocks)  # we're already skipping 1

lp = disk[-1]
lg = 0
gappos = 0
bid = 0
for i, b in enumerate(reversed(blocks)):
    bid = maxid - i
    rp = 0
    while bid - lg > 0 and lg < len(gaps) and rp < b:
        if (gaps[lg] - gappos) == 0:
            lp += gaps[lg] + blocks[lg]
            lg += 1
            gappos = 0
        else:
            dmap[gappos + lp - disk[-1]] = bid
            dmap[len(dmap) - 1 - sum(disk[: 2 * i]) - rp] = 0
            gappos += 1
            rp += 1

print(sum((i + disk[-1]) * e for i, e in enumerate(dmap)))
