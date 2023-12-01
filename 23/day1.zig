const std = @import("std");
// const expect = std.testing.expect;

// test "readFile" {
// }

// const LineReader = struct {
//     reader: std.io.BufferedReader,
//     index: usize = 0,
//     fn next(self: *Self) !?[]const u8 {
//         return try reader.streamUntilDelimiter(buffer, '\n');
//     }
// };

// fn isDigit(c: u8) bool {
//     return switch (c) {
//         '0'...'9' => true,
//         else => false,
//     };
// }

fn enumFromStr(comptime T: type, str: []const u8) !T {
    inline for (@typeInfo(T).Enum.fields) |field| {
        if (std.mem.startsWith(u8, str, field.name))
            return @enumFromInt(field.value);
    }
    return error.NoMatch;
}

const Digit = enum(u4) {
    zero = 0,
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    pub fn fromChar(c: u8) !Digit {
        return switch (c) {
            '0'...'9' => @enumFromInt(try std.fmt.parseInt(u4, &.{c}, 10)),
            else => error.InvalidDigit,
        };
    }
    pub fn fromStr(str: []const u8) !Digit {
        return try enumFromStr(Digit, str);
    }
};

fn getBrokenNumFromLine(line: []const u8, spelled: bool) u7 {
    var number: u7 = undefined;
    for (0..line.len) |i| {
        const digit = Digit.fromChar(line[i]) catch blk: {
            if (!spelled)
                continue;
            break :blk Digit.fromStr(line[i..]) catch {
                continue;
            };
        };

        number = @as(u7, @intCast(@intFromEnum(digit))) * 10;
        break;
    }

    var i = line.len;
    while (i > 0) {
        i -= 1;
        const digit = Digit.fromChar(line[i]) catch blk: {
            if (!spelled or line.len - i < 3)
                continue;
            break :blk Digit.fromStr(line[i..]) catch {
                continue;
            };
        };

        number += @intCast(@intFromEnum(digit));
        break;
    }
    return number;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var file = try std.fs.cwd().openFile("day1.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    // var file = LineReader{.reader = reader};

    var sum: u32 = 0;
    var spelled_sum: u32 = 0;

    while (true) {
        arr.clearRetainingCapacity();
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const line = arr.items;

        // part one
        sum += getBrokenNumFromLine(line, false);

        // part two
        spelled_sum += getBrokenNumFromLine(line, true);
    }

    const stdout = std.io.getStdOut();
    try stdout.writer().print("Sum of literal digits: {d}\n", .{sum});
    try stdout.writer().print("Sum with spelled digits: {d}\n", .{spelled_sum});
}
