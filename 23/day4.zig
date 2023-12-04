const std = @import("std");

// fn help(name: []const u8) !void {
//     std.debug.print("usage: {s}\n", .{name});
//     std.process.exit(1);
// }

pub fn main() !void {
    var buf: [120]u8 = undefined;

    // var args = std.process.args();
    // const name = args.next().?;
    // _ = name;

    var file = try std.fs.cwd().openFile("day4.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var sum: u32 = 0;
    var winning: [10]u7 = undefined;
    // var elf_numbers: [25]u7 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parts = std.mem.tokenizeAny(u8, line, ":|");
        // we don't care about the first part
        _ = parts.next();

        var winning_iter = std.mem.tokenizeAny(u8, parts.next().?, " ");

        var last: usize = 0;
        while (winning_iter.next()) |num| {
            winning[last] = try std.fmt.parseInt(u7, num, 10);
            last += 1;
        }

        var elf_iter = std.mem.tokenizeAny(u8, parts.next().?, " ");

        // last = 0;
        var score: u32 = 0;
        while (elf_iter.next()) |num| {
            for (winning) |w| {
                if (w == try std.fmt.parseInt(u7, num, 10)) {
                    if (score == 0) {
                        score = 1;
                    } else {
                        score *= 2;
                    }
                }
                // if (w + std.fmt.parseInt(u7, num, 10) == 2020) {
                //     var stdout = std.io.getStdOut();
                //     try stdout.writer().print("Found {d} and {d}!\n", .{w, std.fmt.parseInt(u7, num, 10)});
                //     try stdout.writer().print("Product is {d}\n", .{w * std.fmt.parseInt(u7, num, 10)});
                //     break;
                // }
            }
            // elf_numbers[last] = std.fmt.parseInt(u7, num, 10);
            // last += 1;
        }

        sum += score;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{sum});
}
