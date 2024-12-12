from functools import lru_cache
from pathlib import Path

data = Path("day10.in").read_text().splitlines()
size = len(data)
rowsize = len(data[0])
hmap = [[-1] * (rowsize + 2)]
for r in data:
    hmap.append([-1] + [int(c) for c in r] + [-1])

hmap.append([-1] * (rowsize + 2))


def get_strail(trail):
    return ", ".join([f"({x - 1}, {y - 1})" for y, x in trail])


heads = set()


# def dfs(y, x, c, trace):
# @lru_cache
def dfs(y, x, c):
    t = 0
    for dy, dx in [
        (1, 0),
        (-1, 0),
        (0, 1),
        (0, -1),
    ]:
        if hmap[y + dy][x + dx] == c:
            if c == 9:
                heads.add((y + dy, x + dx))
                t += 1
            else:
                t += dfs(y + dy, x + dx, c + 1)
    return t


thc = 0
rating = 0
for y in range(1, size + 1):
    for x in range(1, rowsize + 1):
        if hmap[y][x] == 0:
            rating += dfs(y, x, 1)
            # print(f"found {heads} trailheads starting at ({x - 1}, {y - 1})")
            thc += len(heads)
            heads = set()


print(thc)
print(rating)
