import copy
from enum import Enum
from pprint import pprint

import numpy as np


class Kind(Enum):
    rock = "O"
    stone = "#"
    space = "."


lines = open("day14.in").readlines()
cols = np.array([[Kind(c) for c in line.strip()] for line in lines], dtype=Kind).T


def tilt_north(_map: np.ndarray) -> None:
    for col in _map:
        for i in range(1, len(col)):
            k = col[i]
            if k is Kind.rock:
                new_pos = i - 1
                for j in range(i - 1, -1, -1):
                    if col[j] is not Kind.space:
                        new_pos = j + 1
                        break
                else:
                    new_pos = 0
                if i != new_pos:
                    # print(f"moving rock from {i} to {new_pos}")
                    col[new_pos], col[i] = col[i], col[new_pos]


def to_tuple(_map: np.ndarray) -> tuple:
    return tuple(map(tuple, np.where(_map == Kind.rock)))


def get_load(_map: np.ndarray) -> int:
    return sum([len(_map) - y for _, y in zip(*to_tuple(_map))])


first = copy.deepcopy(cols)
tilt_north(first)
first_load = get_load(first)

memo = {}
cycles = 1000000000


def spin_cycle(_map: np.ndarray) -> int:
    for _ in range(4):
        tilt_north(_map)
        _map = np.rot90(_map)

    return get_load(_map)


cycle = 1
cycle_len = 0
while cycle < cycles:
    load = spin_cycle(cols)
    key = to_tuple(cols)
    if m := memo.get(key):
        print("found matching at cycle", m[1])
        cycle_len = cycle - m[1]
        print("cycle length", cycle_len)
        break

    memo[key] = (load, cycle)
    cycle += 1

remaining = (cycles - cycle) % cycle_len
print("remaining iterations", remaining)
for _ in range(remaining - 1):
    spin_cycle(cols)

cycle_load = spin_cycle(cols)

print(first_load)
print(cycle_load)
