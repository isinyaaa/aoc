const std = @import("std");

const LabelType = enum(u4) {
    Number,
    Ten = 10,
    Joker = 11,
    Queen,
    King,
    Ace,
    pub fn fromChar(c: u8) LabelType {
        return switch (c) {
            '0'...'9' => .Number,
            'T' => .Ten,
            'J' => .Joker,
            'Q' => .Queen,
            'K' => .King,
            'A' => .Ace,
            else => unreachable,
        };
    }
};

const Card = union(enum) {
    value: u4,
    joker: void,
    pub fn fromChar(c: u8) Card {
        const label = LabelType.fromChar(c);
        if (label == LabelType.Joker)
            return Card{ .joker = {} };
        const value = switch (label) {
            .Number => @as(u4, @intCast(c - '0')),
            .Joker => unreachable,
            else => @intFromEnum(label),
        };
        return Card{ .value = value };
    }
    pub fn getValue(self: Card, with_joker: bool) u4 {
        return switch (self) {
            .value => self.value,
            .joker => blk: {
                if (with_joker)
                    break :blk 1;
                break :blk 11;
            },
        };
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
    pub fn fromCards(cards: []const Card, with_joker: bool) HandType {
        var max = [_]u3{1} ** 4;
        var counted = [_]bool{false} ** 5;
        var joker: u3 = 0;
        for (cards[0..4], 0..) |c, i| {
            if (counted[i])
                continue;
            if (with_joker) switch (c) {
                .joker => {
                    joker += 1;
                    continue;
                },
                else => {},
            };
            const v = c.getValue(false);
            var j = i + 1;
            while (j < 5) : (j += 1) {
                if (counted[j])
                    continue;
                if (with_joker) switch (cards[j]) {
                    .joker => {
                        joker += 1;
                        counted[j] = true;
                        continue;
                    },
                    else => {},
                };

                if (v == cards[j].getValue(false)) {
                    max[i] += 1;
                    counted[j] = true;
                }
            }
        }

        std.mem.sort(u3, &max, {}, std.sort.desc(u3));
        std.debug.print("{any}\n", .{max});

        max[0] += joker;

        switch (max[0]) {
            5 => return .five_of_a_kind,
            4 => return .four_of_a_kind,
            3 => {
                switch (max[1]) {
                    2 => return .full_house,
                    1 => return .three_of_a_kind,
                    else => unreachable,
                }
            },
            2 => {
                switch (max[1]) {
                    2 => return .two_pairs,
                    1 => return .one_pair,
                    else => unreachable,
                }
            },
            1 => return .high_card,
            else => unreachable,
        }
    }
};

const Hand = struct {
    cards: []Card,
    hand_type: HandType,
    hand_type_with_joker: HandType,
};

const Play = struct {
    hand: Hand,
    bid: u10,
    pub fn cmp(with_joker: bool, a: Play, b: Play) bool {
        var ta: u3 = undefined;
        var tb: u3 = undefined;
        if (with_joker) {
            ta = @intFromEnum(a.hand.hand_type_with_joker);
            tb = @intFromEnum(b.hand.hand_type_with_joker);
        } else {
            ta = @intFromEnum(a.hand.hand_type);
            tb = @intFromEnum(b.hand.hand_type);
        }
        if (ta < tb)
            return true;
        if (ta > tb)
            return false;

        for (a.hand.cards, b.hand.cards) |ca, cb| {
            const va = ca.getValue(with_joker);
            const vb = cb.getValue(with_joker);
            if (va < vb)
                return true;
            if (va > vb)
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
        const hand = Hand{ .cards = hand_cards, .hand_type = HandType.fromCards(&cards, false), .hand_type_with_joker = HandType.fromCards(&cards, true) };
        std.debug.print("{any}\n", .{hand});
        const bid = try std.fmt.parseInt(u10, line_iter.next().?, 10);
        try plays.append(Play{ .hand = hand, .bid = bid });
    }

    std.mem.sort(Play, plays.items, false, Play.cmp);

    var total_winnings: u32 = 0;
    for (plays.items, 1..) |play, rank| {
        std.debug.print("{any}\n", .{play.hand});
        total_winnings += @as(u32, @intCast(rank)) * play.bid;
    }

    std.mem.sort(Play, plays.items, true, Play.cmp);

    var total_winnings_with_joker: u32 = 0;
    for (plays.items, 1..) |play, rank| {
        std.debug.print("{any}\n", .{play.hand});
        total_winnings_with_joker += @as(u32, @intCast(rank)) * play.bid;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{total_winnings});
    try stdout.writer().print("{d}\n", .{total_winnings_with_joker});
}
