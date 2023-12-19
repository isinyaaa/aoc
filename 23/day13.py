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


def reflects(mirror: np.ndarray, pos: int, wipe: bool = False) -> bool:
    b = pos
    f = pos + 1

    size = len(mirror[:, 0])

    def iter(x):
        return mirror[x, :]

    assert 0 <= b < f < size

    found_smudge = False
    while b > -1 and f < size:
        prev = iter(b)
        nxt = iter(f)
        if (prev == nxt).all():
            b -= 1
            f += 1
        elif wipe and not found_smudge:
            if len(non_zero := np.argwhere(prev ^ nxt)) > 1:
                return False

            non_zero_idx = non_zero[0][0]
            print(f"Wiping smudge at ({b}, {non_zero_idx})")

            # prev[non_zero_idx] ^= prev[non_zero_idx]
            found_smudge = True
            b -= 1
            f += 1
        else:
            return False

    if found_smudge:
        print("Clean mirror")
    elif wipe:
        return False
    else:
        print("Smudged mirror")
    print_reflection(mirror, pos)
    return True


def print_reflection(mirror: np.ndarray, pos: int):
    for i, line in enumerate(mirror):
        print(
            f"{i + 1:02d}",
            " " if i != pos else ">",
            "".join("#" if c else "." for c in line),
        )


notes = 0
wiped = 0
for mirror in mirrors:
    # try to find horizontal match
    for i in range(len(mirror) - 1):
        if reflects(mirror, i):
            note = (i + 1) * 100
            print(note)
            notes += note
            break
    else:
        print("No horizontal match found, transposing...")
        # try to find vertical match
        transposed = mirror.T
        for j in range(len(transposed) - 1):
            if reflects(transposed, j):
                note = j + 1
                print(note)
                notes += note
                break

    # clean smudges
    # try to find horizontal match
    for i in range(len(mirror) - 1):
        if reflects(mirror, i, wipe=True):
            note = (i + 1) * 100
            print(note)
            wiped += note
            break
    else:
        print("No horizontal match found, transposing...")
        # try to find vertical match
        transposed = mirror.T
        for j in range(len(transposed) - 1):
            if reflects(transposed, j, wipe=True):
                note = j + 1
                print(note)
                wiped += note
                break

    print()

print(notes)
print(wiped)
