from pathlib import Path

data = Path("day4.in").read_text().splitlines()


rowsize = len(data[0])
size = len(data)


def parse_xmas(ox, oy) -> int:
    matches = 0
    for dx, dy in [
        # horizontal
        (1, 0),
        (-1, 0),
        # vertical
        (0, 1),
        (0, -1),
        # diagonal
        (1, 1),
        (1, -1),
        (-1, 1),
        (-1, -1),
    ]:
        x, y = ox, oy
        for c in "MAS":
            if not (
                0 <= (x := x + dx) < size
                and 0 <= (y := y + dy) < rowsize
                and data[y][x] == c
            ):
                break
        else:
            matches += 1

    return matches


print(
    sum(
        [
            parse_xmas(x, y)
            for y, row in enumerate(data)
            for x, c in enumerate(row)
            if c == "X"
        ]
    )
)


def parse_x_mas(ox, oy) -> int:
    if not (0 < ox < rowsize - 1 and 0 < oy < size - 1):
        return 0
    return int(
        all(
            [
                {data[oy + dy][ox + dx], data[oy - dy][ox - dx]} == set("MS")
                for dx, dy in [
                    (1, 1),
                    (1, -1),
                ]
            ]
        )
    )


print(
    sum(
        [
            parse_x_mas(x, y)
            for y, row in enumerate(data)
            for x, c in enumerate(row)
            if c == "A"
        ]
    )
)
