from dataclasses import dataclass
from enum import Enum
from pprint import pprint


class Token(Enum):
    unknown = "?"
    damaged = "#"


@dataclass
class Record:
    groups: list[list[Token]]
    checksums: list[int]

    @classmethod
    def from_raw(cls, raw: str) -> "Record":
        raw_record, raw_sizes = raw.split()
        groups = [
            [Token(c) for c in group]
            for group in raw_record.strip(".").split(".")
            if group
        ]
        sizes = list(map(int, raw_sizes.split(",")))
        return Record(groups, sizes)


def count(checksums: list[int]) -> int:
    return sum(checksums) + len(checksums) - 1 if checksums else 0


def count_arr(group: list[Token], size: int, remaining: list[int]) -> int:
    rem_count = count(remaining)

    if len(group) < size + rem_count:
        return 0

    # breakpoint()
    if Token.damaged in group:
        next_dmg = group.index(Token.damaged)

        if not remaining:
            # sequence has to be at known damage
            return 1

        if size < next_dmg:
            # sequence can go up to the first known damage
            arr = len(group[:next_dmg]) - size
            print("meow", arr)
        else:
            # sequence has to be close to the first known damage
            arr = 1
            print("auau", arr)

        if remaining:
            arr *= count_arr(group[next_dmg + size + 1 :], remaining[0], remaining[1:])
            print("meow 2", arr)

    elif remaining:
        arr = sum(
            [
                count_arr(group[i + 1 :], remaining[0], remaining[1:])
                for i in range(size, len(group) - rem_count + 1)
            ]
        )
    else:
        # sequence can be any position
        arr = len(group) - size + 1

    return arr


def count_arrangements(record: Record, gi: int = 0, start: int = 0) -> int:
    if gi == len(record.groups):
        if start != len(record.checksums):
            return 0
        return 1

    cks = record.checksums
    group = record.groups[gi]
    end = len(cks)
    # try to fit the most amount of sequences on the current group
    # the record is only valid if there's at least one way to fit every sequence
    arrangements = 0
    while end > start:
        if count(cks[start:end]) <= len(group):
            if cnt := count_arr(group, cks[start], cks[start + 1 : end]):
                if branch := count_arrangements(record, gi + 1, end):
                    arrangements += cnt * branch
                    print(arrangements, "with ck", cks[start], ":", count(cks[start + 1 : end]), "on", ''.join([g.value for g in group]))
                else:
                    print("discarded", cks[start], ":", count(cks[start + 1 : end]), "on", ''.join([g.value for g in group]))
        end -= 1

    return arrangements


def flatten(xss):
    return [x for xs in xss for x in xs]


arrangements = 0
for line in open("day12.in").readlines():
    print(line)
    record = Record.from_raw(line)
    # breakpoint()
    cnt = count_arrangements(record)
    print("Count:", cnt)
    arrangements += cnt


print(arrangements)
