from pathlib import Path

raw = [int(c) for c in Path("day9.example.in").read_text().strip()]

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

blocks, gaps = raw[2::2], raw[1::2]
disk = [
    (i + 1) // 2 if i % 2 != 0 else 0 for i, c in enumerate(raw[1:]) for _ in range(c)
]


def defrag(block, size):
    ld = 0
    g = 0
    while gaps[g] == 0:
        g += 1
    while g < gaps[g] and ld < len(disk):
        if disk[ld] == 0 and gaps[g] >= size:
            gaps[g] -= size
            while size > 0:
                disk[ld] = block
                ld += 1
                size -= 1
            while ld < len(disk) and disk[ld] != block:
                ld += 1
            while ld < len(disk) and disk[ld] == block:
                disk[ld] = 0
                ld += 1
            break
        if gaps[g] == 0:
            while gaps[g] == 0:
                g += 1
        else:
            g += 1
        while ld < len(disk) and disk[ld] == 0:
            ld += 1


for i in range(len(blocks)):
    defrag(len(blocks) - i, blocks[len(blocks) - i - 1])


# ld = 0
# for i in range(size - 1, 1, -1):
#     if disk[i] == 0:
#         continue
#
#     while ld < size and ld < i:
#         if disk[ld] == 0:
#             disk[ld], disk[i] = disk[i], disk[ld]
#             break
#         ld += 1

print(sum([(i + int(raw[0])) * e for i, e in enumerate(disk)]))
