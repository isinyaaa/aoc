const std = @import("std");

// fn help(name: []const u8) !void {
//     std.debug.print("usage: {s}\n", .{name});
//     std.process.exit(1);
// }

pub fn main() !void {
    var buf: [100]u8 = undefined;

    // var args = std.process.args();
    // const name = args.next().?;
    // _ = name;

    var file = try std.fs.cwd().openFile("day6.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var times = [_]u32{0} ** 4;
    // var dists = [_]u32{0} ** 4;

    const raw_times = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var iter_times = std.mem.tokenizeAny(u8, raw_times, " ");
    _ = iter_times.next();

    var i: usize = 0;
    while (iter_times.next()) |raw_time| {
        // std.debug.print("{s}\n", .{raw_time});
        const time = try std.fmt.parseInt(u32, raw_time, 10);
        times[i] = time;
        i += 1;
    }

    const raw_dists = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var iter_dists = std.mem.tokenizeAny(u8, raw_dists, " ");
    _ = iter_dists.next();

    var total: u64 = 1;

    i = 0;
    while (iter_dists.next()) |raw_dist| {
        const dist = try std.fmt.parseInt(u32, raw_dist, 10);
        std.debug.print("dist: {d}\n", .{dist});
        const time = times[i];
        const delta = std.math.sqrt(time * time - 4 * dist);
        var min_charge = (time - delta) / 2;
        var max_charge = (time + delta) / 2;
        if ((time - min_charge) * min_charge <= dist) {
            std.debug.print("min dist: {d}\n", .{(time - min_charge) * min_charge});
            min_charge += 1;
        }

        if ((time - max_charge) * max_charge <= dist) {
            std.debug.print("max dist: {d}\n", .{(time - max_charge) * max_charge});
            max_charge -= 1;
        }
        std.debug.print("{d} {d}\n", .{ min_charge, max_charge });
        total *= max_charge - min_charge + 1;
        i += 1;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{total});
}
