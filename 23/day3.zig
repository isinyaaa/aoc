const std = @import("std");

const Number = struct {
    value: u32,
    start: usize,
    end: usize,
};

const Symbol = struct {
    value: u8,
    col: usize,
    fn validPartNumber(self: Symbol, num: Number) bool {
        for (self.col - 1..self.col + 2) |i| {
            for (num.start..num.end) |j| {
                if (i == j) {
                    return true;
                }
            }
        }
        return false;
    }
};

const Part = struct {
    symbol: Symbol,
    numbers: []const u32,
};

pub fn main() !void {
    var file = try std.fs.cwd().openFile("day3.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var numberList = std.ArrayList([]const Number).init(allocator);
    defer numberList.deinit();

    var symbolList = std.ArrayList([]const Symbol).init(allocator);
    defer symbolList.deinit();

    var buf: [200]u8 = undefined;
    var line: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |current| {
        var numbers = std.ArrayList(Number).init(allocator);
        defer numbers.deinit();
        var symbols = std.ArrayList(Symbol).init(allocator);
        defer symbols.deinit();
        var inside = false;
        var start: usize = 0;
        // std.debug.print("parsing line {d}:\n{s}\n", .{ line, current });
        for (current, 0..) |c, i| {
            switch (c) {
                '0'...'9' => {
                    if (!inside) {
                        inside = true;
                        start = i;
                    }
                },
                else => {
                    if (inside) {
                        const num = try std.fmt.parseInt(u32, current[start..i], 10);
                        // std.debug.print("found number {d}\n", .{num});
                        try numbers.append(.{ .value = num, .start = start, .end = i });
                        inside = false;
                    }
                    if (c == '.') {
                        continue;
                    }
                    // std.debug.print("found symbol {c}\n", .{c});
                    try symbols.append(.{ .value = c, .col = i });
                },
            }
        }
        if (inside) {
            const num = try std.fmt.parseInt(u32, current[start..], 10);
            // std.debug.print("found number {d}\n", .{num});
            try numbers.append(.{ .value = num, .start = start, .end = current.len });
        }
        try numberList.append(try numbers.toOwnedSlice());
        // std.debug.print("numbers: {any}\n", .{numberList.getLast()});
        try symbolList.append(try symbols.toOwnedSlice());
        // std.debug.print("symbols: {any}\n", .{symbolList.getLast()});
        line += 1;
    }

    var parts = std.ArrayList(Part).init(allocator);
    defer parts.deinit();

    line = 0;
    for (symbolList.items) |symbols| {
        const start = if (line == 0) 0 else line - 1;
        const end = if (line == symbolList.items.len - 1) line + 1 else line + 2;
        // std.debug.print("checking for parts on lines {d} to {d}:\n", .{ start, end });
        for (symbols) |symbol| {
            // std.debug.print("getting numbers for symbol {c} at ({d}, {d})\n", .{ symbol.value, line, symbol.col });
            var valid_numbers = [_]u32{0} ** 6;
            var last: usize = 0;
            for (start..end) |j| {
                for (numberList.items[j]) |number| {
                    if (symbol.validPartNumber(number)) {
                        // std.debug.print("found valid number {d} at ({d}, {d}, {d})\n", .{ number.value, j, number.start, number.end });
                        // try valid_numbers.append(number.value);
                        valid_numbers[last] = number.value;
                        last += 1;
                    }
                }
            }
            try parts.append(.{ .symbol = symbol, .numbers = try allocator.dupe(u32, valid_numbers[0..last]) });
            // std.debug.print("Found part {c} with numbers = {any}\n", .{ symbol.value, valid_numbers });
        }
        line += 1;
    }

    var part_sum: u32 = 0;
    for (parts.items) |part| {
        for (part.numbers) |num| {
            part_sum += num;
        }
    }

    var gear_rs: u32 = 0;
    for (parts.items) |part| {
        // std.debug.print("part {c} has {d} numbers\n", .{ part.symbol.value, part.numbers.len });
        if (part.symbol.value == '*' and part.numbers.len == 2) {
            gear_rs += part.numbers[0] * part.numbers[1];
        }
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("Sum of parts: {d}\n", .{part_sum});
    try stdout.writer().print("Gear ratio sum: {d}\n", .{gear_rs});
}
