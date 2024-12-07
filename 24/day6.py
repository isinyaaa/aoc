from pathlib import Path
from pprint import pprint
from time import sleep

data = Path("day6.in").read_text().splitlines()


pos: complex | None = None
dir: complex | None = None
for y, row in enumerate(data):
    for x, c in enumerate(row):
        if c == "^":
            pos = x + y * 1j
            dir = -1j
            break

assert pos is not None
assert dir is not None

size, rowsize = len(data), len(data[0])


def check_loop(bpos, opos, odir):
    trace = {(opos, odir)}
    dir = odir
    pos = opos + dir
    # print("checking", pos, dir, "for loops")
    i = 0
    while 0 <= pos.real < rowsize and 0 <= pos.imag < size and i < size * rowsize:
        # print("simulating", pos, dir)
        # sleep(0.1)
        if data[int(pos.imag)][int(pos.real)] == "#" or pos == bpos:
            # print("hit at", pos, walked)
            pos -= dir
            dir *= 1j
        elif (pos, dir) in trace:
            # print("loop detected at", pos, dir)
            return True

        trace.add((pos, dir))
        pos += dir
        i += 1
        # pprint(lwalk)

    return False


walked = set()
walked.add(pos)
topts = 0
while (npos := pos + dir) and 0 <= npos.real < rowsize and 0 <= npos.imag < size:
    # print("guard at", pos, dir)
    if data[int(npos.imag)][int(npos.real)] == "#":
        # print("hit at", npos)
        dir *= 1j
    elif npos not in walked:  # pretend there is
        topts += int(check_loop(pos + dir, pos, dir))

    pos += dir
    walked.add(pos)
    # print(pos, dir)

# pprint(walked)
print(len(walked))
print(topts)
