import itertools as it
import math
import re
from functools import lru_cache
from pathlib import Path


def ttoc(x, y):
    return x + y * 1j


expr = re.compile(r"\D*(\d+)\D*(\d+)")


machines = [
    tuple(ttoc(*tuple(int(x) for x in expr.match(t).groups())) for t in ls[:3])
    for _, g in it.groupby(
        Path("day13.in").read_text().splitlines(), lambda x: not x.strip()
    )
    if (ls := list(g))[0].strip()
]

# print(machines)
FUCK = 10000000000000

cost = 0
fcost = 0
for ao, bo, pp in machines:

    @lru_cache
    def fewest(rem, ac, bc):
        if rem.real < 0 or rem.imag < 0 or ac > 100 or bc > 100:
            # print("got to", rem)
            return float("inf")
        if rem == 0:
            # print(c)
            return ac * 3 + bc

        return min(
            fewest(rem - ao, ac + 1, bc),
            fewest(rem - bo, ac, bc + 1),
        )

    if (c := fewest(pp, 0, 0)) < float("inf"):
        cost += c

    pp += FUCK + FUCK * 1j
    d = int(ao.real) * int(bo.imag) - int(ao.imag) * int(bo.real)
    if d != 0:
        p = int(pp.imag) * int(ao.real) - int(pp.real) * int(ao.imag)
        bc = p // d
        ac = (int(pp.real) - bc * int(bo.real)) // int(ao.real)
        if ac * ao + bc * bo == pp:
            fcost += ac * 3 + bc

    # if (c := fewest(gx + gy*1j, 0, 0)) < float("inf"):
    #     fcost += (FUCK // 1000) * c + c


print(cost)
print(fcost)
