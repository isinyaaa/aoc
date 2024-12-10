import itertools as it
from collections import defaultdict
from pathlib import Path

# (y, x) -> x + y*j
data: list[str] = Path("day8.in").read_text().splitlines()

antennaes: dict[str, list[complex]] = defaultdict(list)
for y, line in enumerate(data):
    for x, c in enumerate(line):
        if c != ".":
            antennaes[c].append(x + y * 1j)

size, rowsize = len(data), len(data[0])


def inbounds(c: complex) -> bool:
    x, y = int(c.real), int(c.imag)
    return 0 <= x < rowsize and 0 <= y < size


antis = set()
for ants in antennaes.values():
    for a, b in it.combinations(ants, 2):
        antis.add(a)
        antis.add(b)

        if abs(a) < abs(b):
            m, M = a, b
        else:
            m, M = b, a
        d = M - m

        p = m - d
        while inbounds(p):
            antis.add(p)
            p -= d

        p = M + d
        while inbounds(p):
            antis.add(p)
            p += d

print(len(antis))
