const std = @import("std");

// fn help(name: []const u8) !void {
//     std.debug.print("usage: {s}\n", .{name});
//     std.process.exit(1);
// }

const Connector = enum(u8) {
    Empty = '.',
    Vertical = '|',
    Horizontal = '-',
    UpRight = 'L',
    UpLeft = 'J',
    DownRight = 'F',
    DownLeft = '7',
    Start = 'S',
};

const Path = struct {
    steps: u16,
    conn: Connector,
};

const Direction = enum(u3) {
    None,
    Up,
    Down,
    Left,
    Right,
};

const Position = struct {
    goingTo: Direction,
    x: u8,
    y: u8,
};

const Boundary = struct {
    min: u8,
    max: u8,
};

fn findNext(map: [][]Path, pos: Position) ?Position {
    var x = pos.x;
    var y = pos.y;
    const nextDirection: Direction = switch (pos.goingTo) {
        .Up => blk: {
            y -= 1;
            break :blk switch (map[y][x].conn) {
                .Vertical => .Up,
                .DownRight => .Right,
                .DownLeft => .Left,
                else => return null,
            };
        },
        .Down => blk: {
            y += 1;
            break :blk switch (map[y][x].conn) {
                .Vertical => .Down,
                .UpRight => .Right,
                .UpLeft => .Left,
                else => return null,
            };
        },
        .Left => blk: {
            x -= 1;
            break :blk switch (map[y][x].conn) {
                .Horizontal => .Left,
                .DownRight => .Down,
                .UpRight => .Up,
                else => return null,
            };
        },
        .Right => blk: {
            x += 1;
            break :blk switch (map[y][x].conn) {
                .Horizontal => .Right,
                .DownLeft => .Down,
                .UpLeft => .Up,
                else => return null,
            };
        },
        .None => unreachable,
    };
    return .{ .goingTo = nextDirection, .x = x, .y = y };
}

pub fn main() !void {
    var buf: [143]u8 = undefined;

    // var args = std.process.args();
    // const name = args.next().?;
    // _ = name;

    var file = try std.fs.cwd().openFile("day10.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var map: [142][]Path = undefined;

    var start: Position = undefined;

    var current: [142]Path = undefined;
    var line_count: u8 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var x: u8 = 0;
        for (line) |c| {
            if (c == 'S') {
                start = .{ .goingTo = .None, .x = x, .y = line_count };
                // std.debug.print("start: ({d}, {d})\n", .{ y, x });
            }
            current[x] = .{ .steps = 0, .conn = @enumFromInt(c) };
            x += 1;
        }
        map[line_count] = try allocator.dupe(Path, current[0..x]);
        line_count += 1;
    }

    // map[y] = try allocator.dupe(u8, &empty_line);

    var pos = for ([_]Direction{ Direction.Up, Direction.Right, Direction.Down, Direction.Left }) |direction| {
        if (findNext(&map, .{ .goingTo = direction, .x = start.x, .y = start.y })) |next|
            break next;
    } else unreachable;

    map[pos.y][pos.x].steps = 1;

    // start + first step
    var steps: u16 = 2;
    while (findNext(&map, pos)) |next| {
        pos = next;
        map[pos.y][pos.x].steps = steps;
        std.debug.print("next: ({d}, {d}) = {any} -> {any}\n", .{ pos.y, pos.x, map[pos.y][pos.x], pos.goingTo });
        steps += 1;
    }
    map[start.y][start.x].steps = steps;

    var inside_area: usize = 0;

    // input has padding
    for (map[1..line_count], 1..) |line, y| {
        var crossing: i8 = 0;
        for (line, 0..) |path, x| {
            if (path.steps > 0) {
                const below = map[y + 1][x];
                if (below.steps > 0) {
                    const diff: i32 = if (@max(path.steps, below.steps) - @min(path.steps, below.steps) == 1)
                        @as(i32, path.steps) - below.steps
                    else
                        @as(i32, path.steps % steps) - (below.steps % steps);
                    // going up
                    if (diff == 1) {
                        // std.debug.print("up: ({d}, {d}) = {any} -> {any}\n", .{ y, x, path, below });
                        std.debug.print("U", .{});
                        crossing += 1;
                    } else if (diff == -1) {
                        crossing -= 1;
                        std.debug.print("D", .{});
                        // std.debug.print("down: ({d}, {d}) = {any} -> {any}\n", .{ y, x, path, below });
                    } else std.debug.print("P", .{});
                    // } else std.debug.print("path at: ({d}, {d}) {any}, below: {any}\n", .{ y, x, path, below });
                } else std.debug.print("P", .{});
            } else if (crossing != 0) {
                // std.debug.print("========= adding one: crossing: {d} at ({d}, {d})\n", .{ crossing, y, x });
                std.debug.print("I", .{});
                inside_area += 1;
                // }
            } else std.debug.print(".", .{});
        }
        std.debug.print("\n", .{});
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{steps / 2});
    try stdout.writer().print("{d}\n", .{inside_area});
}
