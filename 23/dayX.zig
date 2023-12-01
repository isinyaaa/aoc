const std = @import("std");

fn help(name: []const u8) !void {
    std.debug.print("usage: {s}\n", .{name});
    std.process.exit(1);
}

pub fn main() !void {
    var buf: [100]u8 = undefined;

    var args = std.process.args();
    const name = args.next().?;
    _ = name;

    var file = try std.fs.cwd().openFile("dayX.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        _ = line;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("\n", .{});
}
