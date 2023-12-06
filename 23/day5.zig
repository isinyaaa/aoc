const std = @import("std");

const Map = struct {
    src: u64,
    dest: u64,
    len: u64,
    fn fromStr(str: []const u8) !Map {
        var iter = std.mem.tokenizeAny(u8, str, " ");
        const dest = try std.fmt.parseInt(u64, iter.next().?, 10);
        const src = try std.fmt.parseInt(u64, iter.next().?, 10);
        const len = try std.fmt.parseInt(u64, iter.next().?, 10);
        return Map{ .src = src, .dest = dest, .len = len };
    }
};

const Range = struct {
    offset: u64,
    len: u64,
    fn cmp(ctx: void, a: Range, b: Range) bool {
        _ = ctx;
        if (a.offset < b.offset) {
            return true;
        } else {
            return false;
        }
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

    var seeds = std.ArrayList(Range).init(allocator);
    defer seeds.deinit();

    var raw_seeds_iter = std.mem.tokenizeAny(u8, seeds_line, " ");
    // skip "seeds:"
    _ = raw_seeds_iter.next();

    while (raw_seeds_iter.next()) |raw_seed| {
        const seed = try std.fmt.parseInt(u64, raw_seed, 10);
        const count = try std.fmt.parseInt(u64, raw_seeds_iter.next().?, 10);
        std.debug.print("seed: {d}, count: {d}\n", .{ seed, count });
        try seeds.append(.{ .offset = seed, .len = count });
    }

    // skip blank and next header
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    // std.debug.print("{s}", .{buf});

    var maps = std.ArrayList(Map).init(allocator);
    defer maps.deinit();

    var section: usize = 1;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            std.debug.print("section: {d}\n", .{section});
            // const sorted = try allocator.dupe(Range, seeds.items);
            // std.sort.heap(Range, sorted, {}, Range.cmp);
            try seeds.ensureTotalCapacity(seeds.items.len + 100);
            var partitions: usize = seeds.items.len;
            var i: usize = 0;
            while (i < partitions) : (i += 1) {
                var range = &seeds.items[i];
                for (maps.items) |map| {
                    // offset < src < offset + len
                    if (range.offset < map.src and map.src < range.offset + range.len) {
                        std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.len - 1, map.dest, map.dest + map.len - 1 });
                        std.debug.print("offset: {d}-{d}\n", .{ range.offset, range.offset + range.len - 1 });
                        // partition from offset to src
                        const partition_base = range.offset;
                        const partition_size = map.src - partition_base;
                        std.debug.print("case C: partitioning seeds: {d}-{d}\n", .{ partition_base, partition_base + partition_size - 1 });
                        seeds.appendAssumeCapacity(.{ .offset = partition_base, .len = partition_size });
                        partitions += 1;
                        range.offset = map.src;
                        range.len -= partition_size;
                    }
                    // src < offset < src + len
                    if (map.src <= range.offset and range.offset < map.src + map.len) {
                        std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.len - 1, map.dest, map.dest + map.len - 1 });
                        std.debug.print("offset: {d}-{d}\n", .{ range.offset, range.offset + range.len - 1 });
                        // range > map
                        if (range.offset + range.len > map.src + map.len) {
                            // partition from map.src + map.len to range.offset + range.len
                            const partition_base = map.src + map.len;
                            const partition_size = (range.offset + range.len) - partition_base;
                            std.debug.print("case B: partitioning seeds: {d}-{d}\n", .{ partition_base, partition_base + partition_size - 1 });
                            seeds.appendAssumeCapacity(.{ .offset = partition_base, .len = partition_size });
                            partitions += 1;
                            range.len = partition_base - range.offset;
                        }
                        const new_dest = range.offset + map.dest - map.src;
                        std.debug.print("mapping seeds: {d}-{d} to {d}-{d}\n", .{ range.offset, range.offset + range.len - 1, new_dest, new_dest + range.len - 1 });
                        range.offset = new_dest;
                        break;
                    }
                }
            }
            section += 1;
            maps.clearRetainingCapacity();
            // skip the header on the next line
            _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
            // std.debug.print("{s}", .{buf});
        } else {
            try maps.append(try Map.fromStr(line));
        }
    }

    try seeds.ensureTotalCapacity(seeds.items.len + 100);
    var partitions: usize = seeds.items.len;
    var i: usize = 0;
    while (i < partitions) : (i += 1) {
        var range = &seeds.items[i];
        for (maps.items) |map| {
            // offset < src < offset + len
            if (range.offset < map.src and map.src < range.offset + range.len) {
                std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.len - 1, map.dest, map.dest + map.len - 1 });
                std.debug.print("offset: {d}-{d}\n", .{ range.offset, range.offset + range.len - 1 });
                // partition from offset to src
                const partition_base = range.offset;
                const partition_size = map.src - partition_base;
                std.debug.print("case C: partitioning seeds: {d}-{d}\n", .{ partition_base, partition_base + partition_size - 1 });
                seeds.appendAssumeCapacity(.{ .offset = partition_base, .len = partition_size });
                partitions += 1;
                range.offset = map.src;
                range.len -= partition_size;
            }
            // src < offset < src + len
            if (map.src <= range.offset and range.offset < map.src + map.len) {
                std.debug.print("map: {d}-{d} : {d}-{d}\n", .{ map.src, map.src + map.len - 1, map.dest, map.dest + map.len - 1 });
                std.debug.print("offset: {d}-{d}\n", .{ range.offset, range.offset + range.len - 1 });
                // range > map
                if (range.offset + range.len > map.src + map.len) {
                    // partition from map.src + map.len to range.offset + range.len
                    const partition_base = map.src + map.len;
                    const partition_size = (range.offset + range.len) - partition_base;
                    std.debug.print("case B: partitioning seeds: {d}-{d}\n", .{ partition_base, partition_base + partition_size - 1 });
                    seeds.appendAssumeCapacity(.{ .offset = partition_base, .len = partition_size });
                    partitions += 1;
                    range.len = partition_base - range.offset;
                }
                const new_dest = range.offset + map.dest - map.src;
                std.debug.print("mapping seeds: {d}-{d} to {d}-{d}\n", .{ range.offset, range.offset + range.len - 1, new_dest, new_dest + range.len - 1 });
                range.offset = new_dest;
                break;
            }
        }
    }

    var lowest = seeds.items[0].offset;
    for (seeds.items) |seed| {
        std.debug.print("seed: {any}\n", .{seed});
        if (seed.offset < lowest)
            lowest = seed.offset;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{lowest});
}
