import itertools as it
from copy import deepcopy
from pathlib import Path

data = tuple(
    list(gs)
    for _, gs in it.groupby(
        Path("day15.in").read_text().splitlines(), key=lambda k: not k.strip()
    )
)

grid: list[list[str]] = [[x for x in row] for row in data[0]]
size, rowsize = len(grid), len(grid[0])

spos = next(
    (x + y * 1j for y, row in enumerate(grid) for x, c in enumerate(row) if c == "@")
)


def ctoii(c: complex) -> tuple[int, int]:
    return int(c.real), int(c.imag)


def pprint(pos):
    gs = deepcopy(grid)
    x, y = ctoii(pos)
    gs[y][x] = "@"
    for y in gs:
        print("".join("".join(y)))


spx, spy = ctoii(spos)
grid[spy][spx] = "."
# pprint(spos)


def get_dir(m: str) -> complex:
    match m:
        case "<":
            return -1
        case ">":
            return 1
        case "v":
            return 1j
        case "^":
            return -1j
        case _:
            raise


movs = list(get_dir(x) for r in data[2] for x in r)


def walk(p: complex, d: complex) -> bool:
    x, y = ctoii(n := p + d)
    g = grid[y][x]
    if g == "#":
        return False
    if g == ".":
        return True
    if m := walk(n, d):
        nx, ny = ctoii(n + d)
        grid[y][x], grid[ny][nx] = grid[ny][nx], g
    return m


npos = spos
for m in movs:
    if walk(npos, m):
        npos += m

print(
    sum(
        (
            x + y * 100
            for y, row in enumerate(grid)
            for x, c in enumerate(row)
            if c == "O"
        )
    )
)

grid = [
    [x for x in "".join(["[]" if c == "O" else c * 2 for c in row])] for row in data[0]
]
size, rowsize = len(grid), len(grid[0])

spos = spx * 2 + spy * 1j
spx, spy = ctoii(spos)
grid[spy][spx] = "."
grid[spy][spx + 1] = "."


def grange(ms, d):
    m, M = min(ms), max(ms)
    if d - 1:
        return range(m, M + 1)
    return range(M, m - 1, -1)


def blocks(p, d):
    x, y = ctoii(n := p + d)
    if not ((0 <= x < rowsize) and (0 <= y < size)):
        return set()
    match grid[y][x]:
        case "#":
            return {-1}
        case "[":
            if int(d.real) == -1:
                return {n, n + 1} | blocks(n, d)
            if int(d.real) == 1:
                return {n, n + 1} | blocks(n + 1, d)
            return {n, n + 1} | blocks(n, d) | blocks(n + 1, d)
        case "]":
            if int(d.real) == -1:
                return {n - 1, n} | blocks(n - 1, d)
            if int(d.real) == 1:
                return {n - 1, n} | blocks(n, d)
            return {n - 1, n} | blocks(n - 1, d) | blocks(n, d)
        case _:
            return set()


npos = spos
for i, m in enumerate(movs):
    # npos = move(npos, m)
    if -1 not in (bs := blocks(npos, m)):
        x, y = ctoii(npos + m)
        if grid[y][x] not in "[]":
            npos += m
            continue

        reals, imags = (
            grange([int(b.real) for b in bs] + [int(npos.real)], int(m.real)),
            grange([int(b.imag) for b in bs] + [int(npos.imag)], int(m.imag)),
        )
        for x in reals:
            for y in imags:
                n = x + y * 1j
                if n in bs:
                    nx, ny = ctoii(n + m)
                    grid[y][x], grid[ny][nx] = grid[ny][nx], grid[y][x]

        npos += m

# pprint(npos)

print(
    sum(
        (
            x + y * 100
            for y, row in enumerate(grid)
            for x, c in enumerate(row)
            if c == "["
        )
    )
)
