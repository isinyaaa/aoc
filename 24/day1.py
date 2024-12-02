from collections import defaultdict
from functools import lru_cache
from pathlib import Path


def atoi(li):
    return [int(i) for i in li]


data = [t.split() for t in (Path.cwd() / "day1.in").read_text().splitlines()]
left, right = zip(*data)
left, right = atoi(left), atoi(right)
print(sum([abs(le - ri) for le, ri in zip(sorted(left), sorted(right), strict=True)]))

bucket = defaultdict(int)
for ri in right:
    bucket[ri] += 1


@lru_cache
def sim(n):
    return n * bucket[n]


print(sum([sim(le) for le in left]))
