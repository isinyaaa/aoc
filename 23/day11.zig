const std = @import("std");

const Position = struct { x: u8, y: u8 };

fn countEmpty(line: []bool, a: u8, b: u8) u8 {
    if (a == b) return 0;
    var lower: u8 = undefined;
    var upper: u8 = undefined;
    if (a > b) {
        lower = b;
        upper = a;
    } else {
        lower = a;
        upper = b;
    }
    var empty: u8 = 0;
    for (line[lower + 1 .. upper]) |is_empty| {
        if (is_empty) empty += 1;
    }
    return empty;
}

pub fn main() !void {
    var buf: [141]u8 = undefined;

    var file = try std.fs.cwd().openFile("day11.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var galaxies: [500]Position = undefined;
    var rows = [_]bool{false} ** 140;
    var cols = [_]bool{true} ** 140;

    var y: u8 = 0;
    var galaxyCount: u16 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var is_empty = true;
        var x: u8 = 0;
        for (line) |c| {
            if (c != '.') {
                galaxies[galaxyCount] = Position{ .x = x, .y = y };
                galaxyCount += 1;
                is_empty = false;
                if (cols[x]) cols[x] = false;
            }
            x += 1;
        }
        if (is_empty) rows[y] = true;
        y += 1;
    }

    var sum: u32 = 0;
    var sum_older: u64 = 0;
    for (galaxies[0 .. galaxyCount - 1], 0..) |a, i| {
        for (galaxies[i + 1 .. galaxyCount]) |b| {
            const expansion = countEmpty(&cols, a.x, b.x) + countEmpty(&rows, a.y, b.y);
            const dx = @abs(@as(i16, @intCast(a.x)) - b.x);
            const dy = @abs(@as(i16, @intCast(a.y)) - b.y);
            sum += dx + dy + expansion;
            sum_older += @as(u64, expansion) * (1000000 - 1) + dx + dy;
        }
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{sum});
    try stdout.writer().print("{d}\n", .{sum_older});
}
