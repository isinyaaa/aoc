const std = @import("std");

pub fn main() !void {
    var stdout = std.io.getStdOut();
    try stdout.writer().print("Hello, world!\n", .{});
}
