const std = @import("std");

// fn help(name: []const u8) !void {
//     std.debug.print("usage: {s}\n", .{name});
//     std.process.exit(1);
// }

const Card = struct {
    value: u4,
    pub fn fromChar(c: u8) Card {
        const value: u4 = switch (c) {
            '0'...'9' => @as(u4, @intCast(c - '0')),
            'T' => 10,
            'J' => 11,
            'Q' => 12,
            'K' => 13,
            'A' => 14,
            else => unreachable,
        } - 1; // as there's no 1 in the deck, we shift the range down
        return Card{ .value = value };
    }
    pub fn cmp(ctx: void, a: Card, b: Card) bool {
        _ = ctx;
        return a.value < b.value;
    }
};

const HandType = enum(u3) {
    high_card,
    one_pair,
    two_pairs,
    three_of_a_kind,
    full_house,
    four_of_a_kind,
    five_of_a_kind,
    pub fn fromCards(cards: []const Card) HandType {
        var max = [_]u3{1} ** 4;
        var counted = [_]bool{false} ** 5;
        for (cards[0..4], 0..) |c, i| {
            if (counted[i])
                continue;
            var j = i + 1;
            while (j < 5) : (j += 1) {
                if (c.value == cards[j].value) {
                    max[i] += 1;
                    counted[j] = true;
                }
            }
        }

        std.mem.sort(u3, &max, {}, std.sort.desc(u3));
        std.debug.print("{any}\n", .{max});

        switch (max[0]) {
            5 => return HandType.five_of_a_kind,
            4 => return HandType.four_of_a_kind,
            3 => {
                switch (max[1]) {
                    2 => return HandType.full_house,
                    1 => return HandType.three_of_a_kind,
                    else => unreachable,
                }
            },
            2 => {
                switch (max[1]) {
                    2 => return HandType.two_pairs,
                    1 => return HandType.one_pair,
                    else => unreachable,
                }
            },
            1 => return HandType.high_card,
            else => unreachable,
        }
    }
};

const Hand = struct {
    cards: []Card,
    handType: HandType,
};

const Play = struct {
    hand: Hand,
    bid: u10,
    pub fn cmp(ctx: void, a: Play, b: Play) bool {
        _ = ctx;
        const ta = @intFromEnum(a.hand.handType);
        const tb = @intFromEnum(b.hand.handType);
        if (ta < tb)
            return true;
        if (ta > tb)
            return false;

        for (a.hand.cards, b.hand.cards) |ca, cb| {
            if (ca.value < cb.value)
                return true;
            if (ca.value > cb.value)
                return false;
        }
        unreachable;
    }
};

pub fn main() !void {
    var buf: [100]u8 = undefined;

    var file = try std.fs.cwd().openFile("day7.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var plays = std.ArrayList(Play).init(allocator);
    defer plays.deinit();

    var cards: [5]Card = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_iter = std.mem.tokenizeAny(u8, line, " ");
        const raw_hand = line_iter.next().?;
        std.debug.print("{s}\n", .{raw_hand});
        for (raw_hand, 0..) |c, i| {
            cards[i] = Card.fromChar(c);
        }
        const hand_cards = try allocator.dupe(Card, &cards);
        // oh well, we're leaking memory
        const hand = Hand{ .cards = hand_cards, .handType = HandType.fromCards(&cards) };
        std.debug.print("{any}\n", .{hand});
        const bid = try std.fmt.parseInt(u10, line_iter.next().?, 10);
        try plays.append(Play{ .hand = hand, .bid = bid });
    }

    std.mem.sort(Play, plays.items, {}, Play.cmp);

    var total_winnings: u32 = 0;
    for (plays.items, 1..) |play, rank| {
        std.debug.print("{any}\n", .{play.hand});
        total_winnings += @as(u32, @intCast(rank)) * play.bid;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{total_winnings});
}
