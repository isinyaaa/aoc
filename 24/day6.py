from pathlib import Path

data = Path("day6.in").read_text().splitlines()


opos, odir = next(
    (x + y * 1j, -1j)
    for y, row in enumerate(data)
    for x, c in enumerate(row)
    if c == "^"
)

size, rowsize = len(data), len(data[0])


def walk(bpos, opos, odir):
    trace = {(opos, odir)}
    dir = odir
    pos = opos + dir
    while 0 <= pos.real < rowsize and 0 <= pos.imag < size:
        if data[int(pos.imag)][int(pos.real)] == "#" or pos == bpos:
            pos -= dir
            dir *= 1j
        elif (pos, dir) in trace:
            return True

        trace.add((pos, dir))
        pos += dir

    if bpos is not None:
        return False
    return {p for p, _ in trace}


walked = walk(None, opos, odir)
assert isinstance(walked, set)
print(len(walked))
print(
    sum(
        walk(
            bpos,
            opos,
            odir,
        )
        is True
        for bpos in walked
    )
)
