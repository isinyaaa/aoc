const std = @import("std");
const Order = std.math.Order;

pub fn main() !void {
    var buf: [120]u8 = undefined;

    var file = try std.fs.cwd().openFile("day4.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var score_sum: u32 = 0;
    var total_cards: usize = 0;
    var winning: [10]u7 = undefined;
    var copies = [_]u32{1} ** 10;

    var i: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // std.debug.print("looking at card {d}\n{s}\n", .{ i + 1, line });
        var parts = std.mem.tokenizeAny(u8, line, ":|");
        // we don't care about the first part
        _ = parts.next();

        var winning_iter = std.mem.tokenizeAny(u8, parts.next().?, " ");
        var last: usize = 0;
        while (winning_iter.next()) |num| {
            winning[last] = try std.fmt.parseInt(u7, num, 10);
            // std.debug.print("found {d}\n", .{winning[last]});
            last += 1;
        }

        const count = copies[i % 10];
        copies[i % 10] = 1;
        total_cards += count;

        last = i + 1;
        var elf_iter = std.mem.tokenizeAny(u8, parts.next().?, " ");
        var score: u32 = 0;
        while (elf_iter.next()) |num| {
            const number = try std.fmt.parseInt(u7, num, 10);
            for (winning) |w| {
                if (w == number) {
                    // std.debug.print("matched {d} with {d}\n", .{ w, number });
                    if (score == 0) {
                        score = 1;
                    } else {
                        score *= 2;
                    }
                    copies[last % 10] += count;
                    // std.debug.print("increased card {d} to {d}\n", .{ last + 1, copies.items[last] });
                    last += 1;
                }
            }
        }

        score_sum += score;
        i += 1;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("Pseudo-score sum: {d}\n", .{score_sum});
    try stdout.writer().print("Total cards: {d}\n", .{total_cards});
}
