import typing as t
from dataclasses import dataclass
from enum import Enum
from functools import lru_cache
from pathlib import Path


class Tile(Enum):
    empty = "."
    fmirror = "/"
    bmirror = "\\"
    hsplit = "-"
    vsplit = "|"

    def sym(self) -> complex:
        return {
            Tile.empty: 0,
            Tile.fmirror: 1 + 1j,
            Tile.bmirror: 1 - 1j,
            Tile.hsplit: 1,
            Tile.vsplit: 1j,
        }[self]


class Position(t.NamedTuple):
    x: int
    y: int

    def __lt__(self, other: "Position") -> bool:  # type: ignore
        return self.x < other.x and self.y < other.y


lit: list[list[int]] = []
_map: list[str] = []
sources: set[Position] = set()


# @lru_cache
def shine(orig: Position, dir: complex) -> int:
    global sources
    sources.add(orig)
    pos = orig
    dist = 0
    while (
        Position(-1, -1)
        < (pos := Position(pos.x + int(dir.real), pos.y + int(dir.imag)))
        < Position(len(_map[0]), len(_map))
    ):
        # print("accessing", pos.x, pos.y, "@", _map[pos.y][pos.x])
        tile = Tile(_map[pos.y][pos.x])
        if not lit[pos.y][pos.x]:
            dist += 1
            lit[pos.y][pos.x] = 1

        if pos in sources:
            return dist

        if tile is Tile.empty:
            continue

        match tile:
            case Tile.fmirror:
                s = int(dir.real or dir.imag)
                udir = dir - s * tile.sym()
                # print("fmirror", pos, dir, "->", udir)
            case Tile.bmirror:
                s = int(dir.real or -dir.imag)
                udir = dir - s * tile.sym()
                # print("bmirror", pos, dir, "->", udir)
            case _:  # split
                if int(dir.real) == 0:
                    if tile is Tile.vsplit:
                        continue

                    # print("hsplit", pos)
                    return dist + shine(pos, -1) + shine(pos, 1)
                elif tile is Tile.hsplit:
                    continue

                # print("vsplit", pos)
                return dist + shine(pos, -1j) + shine(pos, 1j)

        dir = udir
    else:
        return dist


if __name__ == "__main__":
    from pprint import pprint

    _map = (Path.cwd() / "day16.in").read_text().splitlines()
    pprint(_map)
    size = len(_map)
    rowsize = len(_map[0])
    sources = set()
    bound = size * rowsize
    print(bound)

    lit = [[0] * rowsize for _ in _map]
    sources = set()
    p, d = Position(3, -1), 1j
    dist = shine(p, d)
    print("shone through", dist, f"blocks using ({p}, {d})")
    assert dist < bound, dist

    smax = 0
    for x in range(rowsize):
        lit = [[0] * rowsize for _ in _map]
        sources = set()
        p, d = Position(x, -1), 1j
        dist = shine(p, d)
        print("shone through", dist, f"blocks using ({p}, {d})")
        assert dist < bound, dist
        smax = max(smax, dist)

        lit = [[0] * rowsize for _ in _map]
        sources = set()
        p, d = Position(x, size), -1j
        dist = shine(p, d)
        print("shone through", dist, f"blocks using ({p}, {d})")
        assert dist < bound, dist
        smax = max(smax, dist)

    for y in range(size):
        lit = [[0] * rowsize for _ in _map]
        sources = set()
        p, d = Position(-1, y), 1
        dist = shine(p, d)
        print("shone through", dist, f"blocks using ({p}, {d})")
        assert dist < bound, dist
        smax = max(smax, dist)

        lit = [[0] * rowsize for _ in _map]
        sources = set()
        p, d = Position(rowsize, y), -1
        # s = _map[p.y + int(d.imag)]
        # dest = p.x + int(d.real)
        # _map[p.y + int(d.imag)] = s[:dest] + "*" + s[dest + 1 :]
        # pprint(_map)
        # _map[p.y + int(d.imag)] = s
        dist = shine(p, d)
        print("shone through", dist, f"blocks using ({p}, {d})")
        assert dist < bound, dist
        smax = max(smax, dist)

    print("max", smax)
    # pprint(["".join(["#" if e else "." for e in row]) for row in lit])
    # print(sum([min(e, 1) for row in lit for e in row]), "different blocks lit")
