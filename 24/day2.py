import itertools as it
from pathlib import Path

data = [[int(i) for i in li.split()] for li in Path("day2.in").read_text().splitlines()]


def is_safe(rep, sign, bad) -> int:
    for idx, (i, j) in enumerate(it.pairwise(rep)):
        if not (0 < sign * (j - i) < 4):
            if not bad:
                return is_safe(rep[:idx] + rep[idx + 1 :], sign, True) or is_safe(
                    rep[: idx + 1] + rep[idx + 2 :], sign, True
                )
            else:
                return 0

    return 1


safe = 0
for rep in data:
    safe += is_safe(rep, -1 if rep[0] > rep[-1] else 1, False)

print(safe)
