const std = @import("std");
const content = @embedFile("input.txt");

pub fn main() !void {
    var buf: [100]u8 = undefined;

    var args = std.process.args();
    const name = args.next().?;
    _ = name;

    var buffered = std.io.bufferedReader(content);
    var reader = buffered.reader();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        _ = line;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("\n", .{});
}
