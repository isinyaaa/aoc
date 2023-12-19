from dataclasses import dataclass
from enum import Enum
from pprint import pprint


class Kind(Enum):
    rock = "O"
    stone = "#"
    space = "."


lines = open("day14.in").readlines()

cols = [[Kind.space] * len(lines) for _ in range(len(lines[0]) - 1)]
for y, line in enumerate(lines):
    for x, c in enumerate(line.strip()):
        cols[x][y] = Kind(c)

# pprint(cols)

total_load = 0
max_weight = len(lines)
for x, col in enumerate(cols):
    print(x)
    for i in range(1, len(col)):
        k = col[i]
        if k is Kind.rock:
            print(f"found rock at {i}")
            new_pos = i - 1
            for j in range(i - 1, -1, -1):
                if col[j] is not Kind.space:
                    new_pos = j + 1
                    break
            else:
                new_pos = 0
            if i != new_pos:
                print(f"moving rock from {i} to {new_pos}")
                col[new_pos], col[i] = col[i], col[new_pos]
    for y, k in enumerate(col):
        if k is Kind.rock:
            total_load += max_weight - y


# pprint(cols)


print(total_load)
