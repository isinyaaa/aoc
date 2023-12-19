from dataclasses import dataclass
from pprint import pprint


def hash(s: str) -> int:
    hash = 0
    for c in s:
        hash = (hash + ord(c)) * 17 % 256

    return hash


sequences = open("day15.in").read().strip().split(",")

print(sum(hash(seq) for seq in sequences))


@dataclass
class Lens:
    label: str
    focal_length: int


def get_label(s: str) -> str:
    for i, c in enumerate(s):
        if c in "-=":
            return s[:i]

    raise


boxes: list[list[Lens]] = [[] for _ in range(256)]

for seq in sequences:
    i = 0
    while seq[i] not in "-=":
        i += 1
    label = seq[:i]
    cmd = seq[i]
    key = hash(label)
    print("label", label, "key", key)
    box = boxes[key]
    print("box", box)

    if cmd[0] == "-":
        print("removing", label)
        for j in range(len(box) - 1, -1, -1):
            if box[j].label == label:
                box.pop(j)
                break
    else:
        focal_length = int(seq[i + 1 :])
        for j, lens in enumerate(box):
            if lens.label == label:
                print("replacing", label, box[j].focal_length, "->", focal_length)
                box[j].focal_length = focal_length
                break
        else:
            print("appending", label, focal_length)
            box.append(Lens(label, focal_length))

pprint(boxes)

total_focusing_power = 0
for i, box in enumerate(boxes):
    for j, lens in enumerate(box):
        total_focusing_power += (i + 1) * (j + 1) * lens.focal_length

print(total_focusing_power)
