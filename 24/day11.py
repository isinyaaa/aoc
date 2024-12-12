import typing as t
from functools import lru_cache
from pathlib import Path

data = Path("day11.in").read_text().split()


@lru_cache
def step(stone: str) -> tuple[str, ...]:
    if stone == "0":
        return ("1",)
    elif (vl := len(stone)) % 2 == 0:
        b, a = stone[: vl // 2], stone[vl // 2 :]
        return (str(int(b)), str(int(a)))
    else:
        return (str(int(stone) * 2024),)


# 25 steps
fstep: dict[str, t.Sequence[str]] = {}


def manystep(stone):
    if stone in fstep:
        return fstep[stone]
    stones = (stone,)
    for _ in range(25):
        stones = tuple(t for s in stones for t in step(s))
    fstep[stone] = stones
    return stones


for s in data:
    manystep(s)

stones = {d for vs in fstep.values() for d in vs}

# stones count after 50 steps
cmap = {v: sum(len(manystep(d)) for d in manystep(v)) for v in stones}
print(sum(cmap[s25] for d in data for s25 in fstep[d]))
