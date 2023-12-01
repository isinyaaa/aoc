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

fn isDigit(c: u8) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false,
    };
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

    while (true) {
        arr.clearRetainingCapacity();
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const line = arr.items;
        var digits: [2]u8 = undefined;
        for (line) |char| {
            if (isDigit(char)) {
                digits[0] = char;
                break;
            }
        }

        var i = line.len;
        while (i > 0) {
            i -= 1;
            const char = line[i];
            if (isDigit(char)) {
                digits[1] = char;
                break;
            }
        }
        sum += try std.fmt.parseInt(u7, &digits, 10);
    }

    const stdout = std.io.getStdOut();
    try stdout.writer().print("xxx {d}\n", .{sum});
}
