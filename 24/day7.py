from pathlib import Path

data = Path("day7.in").read_text().splitlines()


def vals(nums, i):
    n = nums[i]
    if i == 0:
        yield n
    else:
        for v in vals(nums, i - 1):
            yield v + n
            yield v * n
            yield int(str(v) + str(n))


cali = 0
for row in data:
    res, nums = row.split(":")
    res = int(res)
    nums = [int(x) for x in nums.strip().split()]
    for v in vals(nums, len(nums) - 1):
        if v == res:
            cali += res
            break

print(cali)
