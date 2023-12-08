import sys
import re
from itertools import groupby


def find_ints(s: str) -> list:
    return list(map(int, re.findall(r"\d+", s)))


data = [l.strip() for l in open("day5.example.in").readlines()]
seeds = find_ints(data[0])
splitted = [list(group) for _, group in groupby(data[2:], lambda x: x != "")]
maps = [[find_ints(x) for x in m[1:]] for m in splitted]

print(maps)


def find_inter(r1, r2):
    r1_start, r1_end = r1
    r2_start, r2_end = r2
    i_start = max(r1_start, r2_start)
    i_end = min(r1_end, r2_end)
    if i_start <= i_end:
        return (i_start, i_end)
    else:
        return None


def split_range(r, inter):
    result = set()

    i_start, i_end = inter
    r_start, r_end = r

    if r_start < i_start:
        result.add((r_start, i_start - 1))

    if r_end > i_end:
        result.add((i_end + 1, r_end))

    return result


def as_range(start_count):
    start, count = start_count
    return (start, start + count - 1)


ranges = set(map(as_range, zip(seeds[0::2], seeds[1::2])))

for m in maps:
    shifted_ranges = set()

    for to, start, count in m:
        for r in ranges.copy():
            if overlap := find_inter(r, (start, start + count - 1)):
                ranges.remove(r)
                ranges |= split_range(r, overlap)
                shifted_ranges.add((overlap[0] + to - start, overlap[1] + to - start))

    ranges |= shifted_ranges

answ = min(min(ranges))

print(answ)
