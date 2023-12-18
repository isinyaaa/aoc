import re

# from pprint import pprint
import numpy as np

data = open("day13.in").read()
raw_mirrors = re.split(r"\n\n", data)

mirrors = []
for raw_mirror in raw_mirrors:
    mirror = []
    for line in raw_mirror.splitlines():
        mirror.append([1 if c == "#" else 0 for c in line])
    mirrors.append(np.array(mirror))


def reflects(mirror: np.ndarray, pos: int) -> bool:
    b = pos
    f = pos + 1

    size = len(mirror[:, 0])

    def iter(x):
        return mirror[x, :]

    assert 0 <= b < f < size

    while b > -1 and f < size:
        if (iter(b) == iter(f)).all():
            b -= 1
            f += 1
        else:
            return False

    return True


def print_reflection(mirror: np.ndarray, pos: int):
    for i, line in enumerate(mirror):
        print(
            f"{i + 1:02d}",
            " " if i != pos else ">",
            "".join("#" if c else "." for c in line),
        )


notes = 0
for mirror in mirrors:
    # try to find horizontal match
    for i in range(len(mirror) - 1):
        if reflects(mirror, i):
            print_reflection(mirror, i)
            note = (i + 1) * 100
            print(note)
            notes += note
            break
    else:
        print("No horizontal match found")
        # try to find vertical match
        transposed = mirror.T
        for j in range(len(transposed) - 1):
            if reflects(transposed, j):
                print_reflection(transposed, j)
                note = j + 1
                print(note)
                notes += note
                break
    print()

print(notes)
