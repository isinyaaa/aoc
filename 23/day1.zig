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

fn enumFromStr(comptime T: type, str: []const u8) ?T {
    inline for (@typeInfo(T).Enum.fields) |field| {
        if (std.mem.startsWith(u8, str, field.name))
            return @enumFromInt(field.value);
    }
    return null;
}

const Digit = enum(u7) {
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    pub fn fromChar(c: u8) ?Digit {
        return switch (c) {
            '0'...'9' => @enumFromInt(c - '0'),
            else => null,
        };
    }
    pub fn fromStr(str: []const u8) ?Digit {
        return enumFromStr(Digit, str);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var file = try std.fs.cwd().openFile("day1.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var sum: u32 = 0;
    var spelled_sum: u32 = 0;

    while (true) {
        arr.clearRetainingCapacity();
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const line = arr.items;

        var found_spelled = false;
        for (0..line.len) |i| {
            if (Digit.fromChar(line[i])) |d| {
                const number = @intFromEnum(d) * 10;
                sum += number;
                if (!found_spelled) {
                    spelled_sum += number;
                }
                break;
            } else if (!found_spelled) {
                if (Digit.fromStr(line[i..])) |d| {
                    found_spelled = true;
                    spelled_sum += @intFromEnum(d) * 10;
                }
            }
        }

        found_spelled = false;
        var i: usize = line.len;
        while (i > 0) {
            i -= 1;
            if (Digit.fromChar(line[i])) |d| {
                const number = @intFromEnum(d);
                sum += number;
                if (!found_spelled) {
                    spelled_sum += number;
                }
                break;
            } else if (line.len - i > 2 and !found_spelled) {
                if (Digit.fromStr(line[i..])) |d| {
                    found_spelled = true;
                    spelled_sum += @intFromEnum(d);
                }
            }
        }
    }

    const stdout = std.io.getStdOut();
    try stdout.writer().print("Sum of literal digits: {d}\n", .{sum});
    try stdout.writer().print("Sum with spelled digits: {d}\n", .{spelled_sum});
}
