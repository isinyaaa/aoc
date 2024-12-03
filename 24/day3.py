import re
from pathlib import Path

mulp = re.compile(r"mul\((\d{1,3},\d{1,3})\)")
dop = re.compile(r"do\(\)")
dontp = re.compile(r"don't\(\)")

data = Path("day3.in").read_text().strip()

enabled = True
res = 0
size = len(data)
for i, t in enumerate(data):
    if t == "m":
        if (
            enabled
            and size - i >= 8
            and (m := mulp.match(data[i : i + min(12, size - i)]))
        ):
            ns = m.groups()[0].split(",")
            a, b = int(ns[0]), int(ns[1])
            res += a * b
    elif t == "d" and size - i >= 12:
        if dop.match(data[i : i + min(4, size - i)]):
            enabled = True
        elif dontp.match(data[i : i + min(7, size - i)]):
            enabled = False


print(res)
