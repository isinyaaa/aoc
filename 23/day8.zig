const std = @import("std");

// fn help(name: []const u8) !void {
//     std.debug.print("usage: {s}\n", .{name});
//     std.process.exit(1);
// }

// const Direction = enum {
//     left,
//     right,
// };

const Node = struct { left: []const u8, right: []const u8 };

pub fn gcd(x: usize, y: usize) usize {
    var _a: usize = undefined;
    var _b: usize = undefined;
    if (x > y) {
        _a = x;
        _b = y;
    } else {
        _b = x;
        _a = y;
    }
    var rem = _a % _b;
    while (rem != 0) : (rem = _a % _b) {
        _a = _b;
        _b = rem;
    }
    return _b;
}

pub fn main() !void {
    var buf: [300]u8 = undefined;

    // var args = std.process.args();
    // const name = args.next().?;
    // _ = name;

    var file = try std.fs.cwd().openFile("day8.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var map = std.StringHashMap(Node).init(allocator);
    defer map.deinit();

    const instructions = try allocator.dupe(u8, try reader.readUntilDelimiterOrEof(&buf, '\n') orelse unreachable);
    var starting_nodes = std.ArrayList([]const u8).init(allocator);
    defer starting_nodes.deinit();

    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var raw_iter = std.mem.tokenizeAny(u8, line, " =(),");
        const key = try allocator.dupe(u8, raw_iter.next().?);
        if (key[2] == 'A')
            try starting_nodes.append(key);
        try map.put(key, .{
            .left = try allocator.dupe(u8, raw_iter.next().?),
            .right = try allocator.dupe(u8, raw_iter.next().?),
        });
    }

    std.debug.print("Starting nodes: {any}\n", .{starting_nodes.items});

    var pos: []const u8 = undefined;
    var steps: usize = 0;
    var lcm: usize = 1;
    for (starting_nodes.items) |start| {
        steps = 0;
        pos = start;
        while (pos[2] != 'Z') : (steps += 1) {
            const possibilities = map.get(pos) orelse unreachable;
            pos = switch (instructions[steps % instructions.len]) {
                'L' => possibilities.left,
                'R' => possibilities.right,
                else => unreachable,
            };
        }
        if (lcm != 1) {
            lcm *= steps / gcd(lcm, steps);
        } else lcm = steps;
    }

    pos = "AAA";
    steps = 0;
    while (!std.mem.startsWith(u8, pos, "ZZZ")) : (steps += 1) {
        const possibilities = map.get(pos) orelse unreachable;
        pos = switch (instructions[steps % instructions.len]) {
            'L' => possibilities.left,
            'R' => possibilities.right,
            else => unreachable,
        };
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{steps});
    try stdout.writer().print("{d}\n", .{lcm});
}
