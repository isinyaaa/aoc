from pathlib import Path

data = {
    x + y * 1j: c
    for x, r in enumerate(Path("day12.in").read_text().splitlines())
    for y, c in enumerate(r)
}

regs = {p: {p} for p in data}

# dfs + union find
for p, v in data.items():
    for d in (1, -1, 1j, -1j):
        n = p + d
        if data.get(n) == v:
            regs[p] |= regs[n]
            for r in regs[n]:
                regs[r] = regs[p]


# remove dups, keys are not needed
regs = {tuple(reg) for reg in regs.values()}


# get the boundary
def get_edges(reg):
    return {(p, d) for d in (1, -1, 1j, -1j) for p in reg if p + d not in reg}


print(sum(len(reg) * len(get_edges(reg)) for reg in regs))


def get_sides(reg):
    es = get_edges(reg)
    # exclude adjacent edges
    return es - {(p + d * 1j, d) for p, d in es}


print(sum(len(reg) * len(get_sides(reg)) for reg in regs))
