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
    start: u64,
    end: u64,
    fn intersect(self: Range, other: Range) ?Range {
        const start = @max(self.start, other.start);
        const end = @min(self.end, other.end);
        if (start < end) {
            return Range{ .start = start, .end = end };
        }
        return null;
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

    var single_seeds = std.ArrayList(u64).init(allocator);
    defer single_seeds.deinit();

    var ranged_seeds = std.ArrayList(Range).init(allocator);
    defer ranged_seeds.deinit();

    var raw_seeds_iter = std.mem.tokenizeAny(u8, seeds_line, " ");
    // skip "seeds:"
    _ = raw_seeds_iter.next();

    while (raw_seeds_iter.next()) |raw_seed| {
        const seed = try std.fmt.parseInt(u64, raw_seed, 10);
        const count = try std.fmt.parseInt(u64, raw_seeds_iter.next().?, 10);
        try single_seeds.append(seed);
        // pretend count is another seed for part 1
        try single_seeds.append(count);
        try ranged_seeds.append(.{ .start = seed, .end = seed + count - 1 });
    }

    // skip blank and next header
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');

    var maps_per_section: [7][]Map = undefined;

    var section_maps: [100]Map = undefined;

    var last_map: u8 = 0;
    var section_number: u4 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            maps_per_section[section_number] = try allocator.dupe(Map, section_maps[0..last_map]);
            section_number += 1;
            last_map = 0;
            // skip the header on the next line
            _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
        } else {
            section_maps[last_map] = try Map.fromStr(line);
            last_map += 1;
        }
    } else maps_per_section[section_number] = try allocator.dupe(Map, section_maps[0..last_map]);

    for (maps_per_section) |maps| {
        for (single_seeds.items) |*seed| {
            for (maps) |map| {
                if (map.src <= seed.* and seed.* <= map.src + map.len - 1) {
                    seed.* = seed.* + map.dest - map.src;
                    break;
                }
            }
        }
        try ranged_seeds.ensureTotalCapacity(ranged_seeds.items.len + 100);
        var i: usize = 0;
        while (i < ranged_seeds.items.len) : (i += 1) {
            var range = &ranged_seeds.items[i];
            for (maps) |map| {
                if (range.intersect(Range{ .start = map.src, .end = map.src + map.len - 1 })) |inter| {
                    if (inter.start > range.start) {
                        ranged_seeds.appendAssumeCapacity(.{ .start = range.start, .end = inter.start - 1 });
                        range.start = inter.start;
                    } else if (inter.end < range.end) {
                        ranged_seeds.appendAssumeCapacity(.{ .start = inter.end + 1, .end = range.end });
                        range.end = inter.end;
                    }
                    range.start = range.start + map.dest - map.src;
                    range.end = range.end + map.dest - map.src;
                    break;
                }
            }
        }
    }

    var lowest_seed = single_seeds.items[0];
    for (single_seeds.items) |seed| {
        if (seed < lowest_seed)
            lowest_seed = seed;
    }

    var lowest_range = ranged_seeds.items[0].start;
    for (ranged_seeds.items) |seed| {
        if (seed.start < lowest_range)
            lowest_range = seed.start;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{lowest_seed});
    try stdout.writer().print("{d}\n", .{lowest_range});
}
