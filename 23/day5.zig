const std = @import("std");

const Map = struct {
    src: u64,
    dest: u64,
    length: u64,
    fn fromStr(str: []const u8) !Map {
        var iter = std.mem.tokenizeAny(u8, str, " ");
        const dest = try std.fmt.parseInt(u64, iter.next().?, 10);
        const src = try std.fmt.parseInt(u64, iter.next().?, 10);
        const length = try std.fmt.parseInt(u64, iter.next().?, 10);
        return Map{ .src = src, .dest = dest, .length = length };
    }
};

pub fn main() !void {
    var buf: [800]u8 = undefined;

    var file = try std.fs.cwd().openFile("day5.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    const seeds_line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var seeds = std.ArrayList(u64).init(allocator);
    defer seeds.deinit();

    var raw_seeds_iter = std.mem.tokenizeAny(u8, seeds_line, " ");
    // skip "seeds:"
    _ = raw_seeds_iter.next();

    while (raw_seeds_iter.next()) |raw_seed| {
        const seed = try std.fmt.parseInt(u64, raw_seed, 10);
        // std.debug.print("seed: {d}\n", .{seed});
        try seeds.append(seed);
    }

    // skip blank and next header
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    // std.debug.print("{s}", .{buf});

    var maps = std.ArrayList(Map).init(allocator);
    defer maps.deinit();

    // var section: usize = 1;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            // std.debug.print("section: {d}\n", .{section});
            for (seeds.items) |*dest| {
                const src = dest.*;
                for (maps.items) |map| {
                    // std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.length - 1, map.dest, map.dest + map.length - 1 });
                    if (map.src <= src and src < map.src + map.length) {
                        const new_dest = src + map.dest - map.src;
                        // std.debug.print("mapping seed: {d} to {d}\n", .{ src, new_dest });
                        dest.* = new_dest;
                        break;
                    }
                }
            }
            // section += 1;
            maps.clearRetainingCapacity();
            // skip the header on the next line
            _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
            // std.debug.print("{s}", .{buf});
        } else {
            try maps.append(try Map.fromStr(line));
        }
    }

    for (seeds.items) |*dest| {
        const src = dest.*;
        for (maps.items) |map| {
            // std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.length - 1, map.dest, map.dest + map.length - 1 });
            if (map.src <= src and src < map.src + map.length) {
                const new_dest = src + map.dest - map.src;
                std.debug.print("mapping seed: {d} to {d}\n", .{ src, new_dest });
                dest.* = new_dest;
                break;
            }
        }
    }

    var lowest = seeds.items[0];
    for (seeds.items) |seed| {
        std.debug.print("seed: {d}\n", .{seed});
        if (seed < lowest)
            lowest = seed;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{lowest});
}
