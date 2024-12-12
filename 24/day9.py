from dataclasses import dataclass
from pathlib import Path

raw = [int(c) for c in Path("day9.in").read_text().strip()]

disk = [
    (i + 1) // 2 if i % 2 != 0 else 0 for i, c in enumerate(raw[1:]) for _ in range(c)
]

size = len(disk)

ld = 0
for i in range(size - 1, 1, -1):
    if disk[i] == 0:
        continue

    while ld < size and ld < i:
        if disk[ld] == 0:
            disk[ld], disk[i] = disk[i], disk[ld]
            break
        ld += 1

print(sum([(i + raw[0]) * e for i, e in enumerate(disk)]))


@dataclass
class Block:
    start: int
    size: int
    val: int = 0
    next: "Block | None" = None


blocks = Block(0, raw[0], -1)
lg = blocks
p = raw[0]
for i, d in enumerate(raw[1:]):
    if i % 2 == 0:  # gap
        lg.next = Block(p, d)
        lg = lg.next
    else:
        lg.next = Block(p, d, (i + 1) // 2)
        lg = lg.next
    p += d


def defrag(block, size):
    g = blocks
    while g is not None:
        if g.val == block:
            return None
        if g.val == 0:
            if g.size == size:
                g.val = block
                return g.next
            elif g.size > size:
                g.val = block
                g.next = Block(g.start + size, g.size - size, 0, g.next)
                g.size = size
                return g.next
        g = g.next
    return None


bc = len(raw) // 2
for i, b in enumerate(reversed(raw[2::2])):
    bid = bc - i
    if b := defrag(bid, b):
        while b is not None:
            if b.val == bid:
                b.val = 0
                break
            b = b.next
        else:
            raise ValueError("block not found")


checksum = 0
b = blocks
while b is not None:
    if b.val > 0:
        for x in range(b.size):
            checksum += (b.start + x) * b.val
    b = b.next

print(checksum)
