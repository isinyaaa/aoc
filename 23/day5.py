from typing import NamedTuple
import re
from itertools import groupby


def find_ints(s: str) -> list:
    return list(map(int, re.findall(r"\d+", s)))


data = open("day5.example.in").readlines()
seeds = find_ints(data[0])
maps = []
for _, lines in groupby(data[2:], key=lambda x: x != "\n"):
    maps.append([ints for line in lines if (ints := find_ints(line))])


class Range(NamedTuple):
    start: int
    end: int

    @classmethod
    def from_count(cls, start, count):
        return cls(start, start + count - 1)


def find_inter(r1: Range, r2: Range):
    i_start = max(r1.start, r2.start)
    i_end = min(r1.end, r2.end)
    if i_start <= i_end:
        return Range(i_start, i_end)
    else:
        return None


def split_range(r, inter):
    result = set()

    if r.start < inter.start:
        result.add(Range(r.start, inter.start - 1))

    if r.end > inter.end:
        result.add(Range(inter.end + 1, inter.end))

    return result


def as_range(start_count):
    start, count = start_count
    return (start, start + count - 1)


ranges = set(map(Range.from_count, seeds[0::2], seeds[1::2]))

for m in maps:
    shifted_ranges = set()

    for to, start, count in m:
        for r in ranges.copy():
            if overlap := find_inter(r, Range.from_count(start, count)):
                ranges.remove(r)
                ranges |= split_range(r, overlap)
                offset = to - start
                shifted_ranges.add(Range(overlap.start + offset, overlap.end + offset))

    ranges |= shifted_ranges

answ = min(min(ranges))

print(answ)
