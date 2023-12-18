from dataclasses import dataclass
from functools import cache
from enum import Enum
from pprint import pprint
import re


class Token(Enum):
    unknown = "?"
    damaged = "#"
    operational = "."


def next_state(record: str) -> int:
    return next((i for i, t in enumerate(record) if t != record[0]), 0)


@cache
def count_arr(record: str, sizes: tuple[int]) -> int:
    # breakpoint()
    print(record, sizes)
    if not sizes:
        if Token.damaged.value in record:
            return 0
        return 1
    if not record:
        return 0

    rem = sum([size + 1 for size in sizes]) - 1

    match Token(record[0]):
        case Token.unknown:
            # fork
            # usable_size = sum([len(group) for group in record.split(".")])
            # if usable_size -
            #     return 0
            # else:
            #     return count_arr(
            #         Token.damaged.value + record[1:], sizes
            #     ) + count_arr(Token.operational.value + record[1:], sizes)
            #
            if rem > len(record):
                print("giving up on")
                return 0

            if rem != len(record):
                print("forking useless")
                useless_fork = count_arr(record[1:], sizes)
            else:
                useless_fork = 0
            print("forking")
            return count_arr(Token.damaged.value + record[1:], sizes) + useless_fork
        case Token.damaged:
            # make sure that the next damaged is within the current size
            if sizes[0] > len(record):
                print("giving up on")
                return 0

            for i in range(sizes[0]):
                if record[i] == Token.operational.value:
                    print("giving up on")
                    return 0

            if sizes[0] < len(record) and record[sizes[0]] == Token.damaged.value:
                print("cant violate contiguous group")
                return 0

            print("using", sizes[0])
            return count_arr(record[sizes[0] + 1 :], sizes[1:])
        case Token.operational:
            # fuck 'em
            if len(record) > 1:
                print("skipping operational")
                return count_arr(record[1:], sizes)

            print("giving up on", record)
            return 0


def unfold(record, sizes):
    return ("?".join([record] * 5), sizes * 5)


lines = open("day12.in").readlines()

arrangements = 0
unfolded_arr = 0
for line in lines:
    record, raw_sizes = line.split()
    record = re.sub(r"\.+", ".", record)
    sizes = tuple(map(int, raw_sizes.split(",")))
    cnt = count_arr(record.strip("."), sizes)
    arrangements += cnt
    print(cnt)
    unf = count_arr(*unfold(record, sizes))
    unfolded_arr += unf
    print(unf)
    print()


print(arrangements)
print(unfolded_arr)
