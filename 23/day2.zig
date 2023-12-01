const std = @import("std");

const Game = struct {
    red: u8 = 0,
    blue: u8 = 0,
    green: u8 = 0,
    pub fn newRoundFromStr(self: *Game, str: []const u8) void {
        var ball = std.mem.splitAny(u8, str, " ");
        const number = std.fmt.parseInt(u8, ball.next().?, 10) catch unreachable;
        switch (ball.next().?[0]) {
            'r' => {
                self.red = @max(self.red, number);
            },
            'g' => {
                self.green = @max(self.green, number);
            },
            'b' => {
                self.blue = @max(self.blue, number);
            },
            else => unreachable,
        }
    }
    pub fn isPossible(self: Game, limit: Game) bool {
        return self.red <= limit.red and self.green <= limit.green and self.blue <= limit.blue;
    }
};

fn help(name: []const u8) !void {
    std.debug.print("usage: {s} R G B\n", .{name});
    std.process.exit(1);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var args = try std.process.argsWithAllocator(allocator);
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

    const limit = Game{ .red = red, .green = green, .blue = blue };

    // var games = std.ArrayList(Game).init(allocator);
    // defer games.deinit();

    const reader = std.io.getStdIn().reader();
    var id: usize = 1;
    var id_sum: u32 = 0;
    while (true) {
        reader.streamUntilDelimiter(buffer.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const line = buffer.items;

        var rounds = std.mem.tokenizeAny(u8, line, ":;,");
        // we get the game number from id
        _ = rounds.next();

        var game = Game{};
        while (rounds.next()) |round| {
            game.newRoundFromStr(std.mem.trim(u8, round, " "));
        }

        if (game.isPossible(limit))
            // try games.append(game);
            id_sum += @as(u32, @intCast(id));
        id += 1;
        buffer.clearRetainingCapacity();
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("Sum of IDs of possible games: {d}\n", .{id_sum});
}
