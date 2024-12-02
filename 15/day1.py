from pathlib import Path

data = (Path.cwd() / "day1.in").read_text()

floor = 0
i = 0
for i, p in enumerate(data):
    if p == "(":
        floor += 1
    else:
        floor -= 1

    if floor < 0:
        break

print(i + 1)
