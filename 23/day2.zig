const std = @import("std");

const Color = enum(u8) {
    red,
    green,
    blue,
    fn fromChar(char: u8) Color {
        return switch (char) {
            'r' => Color.red,
            'g' => Color.green,
            'b' => Color.blue,
            else => unreachable,
        };
    }
};

const Game = struct {
    cubes: [3]u8,
    pub fn isPossible(self: Game, limit: [3]u8) bool {
        for (0..self.cubes.len) |i| {
            if (self.cubes[i] > limit[i])
                return false;
        }
        return true;
    }
    fn setPower(self: *const Game) u32 {
        var power: u32 = 1;
        for (self.cubes) |cube| {
            power *= cube;
        }
        return power;
    }
};

fn help(name: []const u8) !void {
    std.debug.print("usage: {s} R G B\n", .{name});
    std.process.exit(1);
}

pub fn main() !void {
    var args = std.process.args();
    const name = args.next().?;

    const red = std.fmt.parseInt(u8, args.next().?, 10) catch {
        return help(name);
    };
    const green = std.fmt.parseInt(u8, args.next().?, 10) catch {
        return help(name);
    };
    const blue = std.fmt.parseInt(u8, args.next().?, 10) catch {
        return help(name);
    };

    const limit = [_]u8{ red, green, blue };

    var file = try std.fs.cwd().openFile("day2.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var buf: [200]u8 = undefined;
    var id: usize = 1;
    var id_sum: u32 = 0;
    var set_power_sum: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var rounds = std.mem.tokenizeAny(u8, line, ":;");
        // we get the game number from id
        _ = rounds.next();

        var game = Game{ .cubes = undefined };
        while (rounds.next()) |round| {
            // std.debug.print("Round: {s}\n", .{round});
            var entries = std.mem.tokenizeAny(u8, round, ",");
            while (entries.next()) |entry| {
                // std.debug.print("Entry: {s}\n", .{entry});
                var parts = std.mem.tokenizeAny(u8, entry, " ");
                const number = std.fmt.parseInt(u8, parts.next().?, 10) catch unreachable;
                const color = Color.fromChar(parts.next().?[0]);
                const ci = @intFromEnum(color);
                game.cubes[ci] = @max(number, game.cubes[ci]);
            }
        }

        set_power_sum += game.setPower();

        if (game.isPossible(limit))
            id_sum += @as(u32, @intCast(id));
        id += 1;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("Sum of IDs of possible games: {d}\n", .{id_sum});
    try stdout.writer().print("Sum of set powers of all games: {d}\n", .{set_power_sum});
}
