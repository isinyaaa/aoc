const std = @import("std");

fn findRange(comptime T: type, time: T, dist: T) T {
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
    return max_charge - min_charge + 1;
}

pub fn main() !void {
    var buf: [100]u8 = undefined;

    var file = try std.fs.cwd().openFile("day6.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var times = [_]u32{0} ** 4;
    var big_time: u64 = 0;

    const raw_times = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var iter_times = std.mem.tokenizeAny(u8, raw_times, " ");
    _ = iter_times.next();

    var i: usize = 0;
    while (iter_times.next()) |raw_time| {
        // std.debug.print("{s}\n", .{raw_time});
        const time = try std.fmt.parseInt(u32, raw_time, 10);
        times[i] = time;
        big_time *= std.math.pow(u32, 10, @as(u32, @intCast(raw_time.len)));
        big_time += time;
        i += 1;
    }

    const raw_dists = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var iter_dists = std.mem.tokenizeAny(u8, raw_dists, " ");
    _ = iter_dists.next();

    var total: u64 = 1;

    var big_dist: u64 = 0;

    i = 0;
    while (iter_dists.next()) |raw_dist| {
        const dist = try std.fmt.parseInt(u32, raw_dist, 10);
        std.debug.print("dist: {d}\n", .{dist});
        const time = times[i];
        total *= findRange(u32, time, dist);
        big_dist *= std.math.pow(u32, 10, @as(u32, @intCast(raw_dist.len)));
        big_dist += dist;
        i += 1;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{total});
    try stdout.writer().print("{d}\n", .{findRange(u64, big_time, big_dist)});
}
