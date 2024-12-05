import itertools as it
from collections import defaultdict
from pathlib import Path

data = Path("day5.in").read_text().splitlines()

rules = defaultdict(set)
i = 0
for i, r in enumerate(data):
    if not r.strip():
        break

    v, k = r.split("|")
    v, k = int(v), int(k)
    rules[k].add(v)

updates = [[int(x) for x in u.split(",")] for u in data[i + 1 :]]

invalid = []
midder = 0
for i, u in enumerate(updates):
    for k, v in it.pairwise(u):
        if rules[k] and v in rules[k]:
            # print(f"Found {v} in {rules[k]} for {i}")
            invalid.append(u)
            break
    else:
        midder += u[len(u) // 2]

print(midder)


def dfs(vtx: list[int], u: int, disc: set[int], stack: list[int]):
    disc.add(u)
    for v in rules[u]:
        if v in vtx and v not in disc:
            dfs(vtx, v, disc, stack)

    stack.append(u)


def topo(update):
    disc = set()
    stack = []
    for i in update:
        if i not in disc:
            dfs(update, i, disc, stack)

    return stack


print(sum([topo(u)[len(u) // 2] for u in invalid]))
