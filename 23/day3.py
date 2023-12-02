import re
from dataclasses import dataclass
from pprint import pprint


@dataclass
class Number:
    val: int
    start: int
    end: int


@dataclass
class Symbol:
    var: str
    col: int


@dataclass
class Part:
    symbol: Symbol
    numbers: list[Number]


if __name__ == "__main__":
    numberlist = []
    symbollist = []
    with open("day3.in", "r") as f:
        for line in f.readlines():
            numbers = []
            for match in re.finditer(r"(\d+)", line):
                numbers.append(
                    Number(int(match.group(0)), match.start(0), match.end(0))
                )
            numberlist.append(numbers)

            symbols = []
            for match in re.finditer(r"([^\d\.\n])", line):
                symbols.append(Symbol(match.group(0), match.start(0)))
            symbollist.append(symbols)

    # pprint(numberlist)
    # pprint(symbollist)
    # print("=====")

    parts = []
    for line, symbols in enumerate(symbollist):
        start = 0 if line == 0 else line - 1
        end = line + 1 if line == len(symbollist) - 1 else line + 2
        for symbol in symbols:
            part_numbers = []
            valid_range = range(symbol.col - 1, symbol.col + 2)
            for numbers in numberlist[start:end]:
                for number in numbers:
                    if any(
                        pos in valid_range for pos in range(number.start, number.end)
                    ):
                        # print(f"Found number {number.val} for part {symbol.var}")
                        # print(f"number: ({number.start}, {number.end})")
                        # print(f"symbol: {symbol.col}")
                        part_numbers.append(number)
            parts.append(Part(symbol, part_numbers))
            # print(parts[-1])

    # print("=====")

    part_num_sum = 0
    for part in parts:
        # print(f"Part: {part.symbol.var}")
        ps = sum([number.val for number in part.numbers])
        # print(part.numbers)
        # print(ps)
        part_num_sum += ps

    gear_ratio_sum = 0
    for part in parts:
        if part.symbol.var == "*" and len(part.numbers) == 2:
            gear_ratio_sum += part.numbers[0].val * part.numbers[1].val

    print("Sum of parts", part_num_sum)
    print("Gear ratio sum", gear_ratio_sum)
