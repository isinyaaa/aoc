if __name__ == "__main__":
    with open("day1.in") as f:
        lines = f.readlines()

    numbers = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    ]

    def char_to_int(c: str) -> int | None:
        if ord("0") <= ord(c) <= ord("9"):
            return int(c)

    def spelled_to_int(s: str) -> int | None:
        for i, num in enumerate(numbers):
            if s.startswith(num):
                return i

    sum = 0
    ssum = 0
    for line in lines:
        found_spelled = False
        for i in range(len(line)):
            if (char := char_to_int(line[i])) is not None:
                number = char * 10
                sum += number
                if not found_spelled:
                    ssum += number
                break

            if not found_spelled and (spelled := spelled_to_int(line[i:])) is not None:
                found_spelled = True
                ssum += spelled * 10

        found_spelled = False
        for i in range(len(line) - 1, -1, -1):
            if (char := char_to_int(line[i])) is not None:
                sum += char
                if not found_spelled:
                    ssum += char
                break

            if (
                len(line) - i > 2
                and not found_spelled
                and (spelled := spelled_to_int(line[i:])) is not None
            ):
                found_spelled = True
                ssum += spelled

    print("sum:", sum)
    print("spelled sum:", ssum)
