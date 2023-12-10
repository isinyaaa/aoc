const std = @import("std");

fn findNext(seq: []i64) i64 {
    const end = seq.len - 1;
    var last = seq[0];
    if (seq[end] == seq[end - 1]) {
        for (seq[1 .. end - 1]) |e| {
            if (e != last)
                break;
            last = e;
        } else return seq[end];
    }

    var diff: [25]i64 = undefined;
    var i: u5 = 0;
    for (seq[1..]) |elem| {
        diff[i] = elem - last;
        last = elem;
        i += 1;
    }
    return seq[end] + findNext(diff[0..i]);
}

fn findPrev(seq: []i64) i64 {
    var first = seq[0];
    if (first == seq[1]) {
        for (seq[2..]) |e| {
            if (e != first)
                break;
            first = e;
        } else return seq[0];
    }

    var diff: [25]i64 = undefined;
    var i: u5 = 0;
    for (seq[1..]) |elem| {
        diff[i] = elem - first;
        first = elem;
        i += 1;
    }
    return seq[0] - findPrev(diff[0..i]);
}

pub fn main() !void {
    var buf: [200]u8 = undefined;

    var file = try std.fs.cwd().openFile("day9.in", .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var sequences = std.ArrayList([]i64).init(allocator);
    defer sequences.deinit();

    var seq: [25]i64 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var raw_seq_iter = std.mem.tokenizeAny(u8, line, " ");
        var i: u5 = 0;
        while (raw_seq_iter.next()) |raw_seq| {
            const element = try std.fmt.parseInt(i64, raw_seq, 10);
            seq[i] = element;
            i += 1;
        } else try sequences.append(try allocator.dupe(i64, seq[0..i]));
    }

    var sum_next: i64 = 0;
    var sum_prev: i64 = 0;

    for (sequences.items) |s| {
        const next = findNext(s);
        const prev = findPrev(s);
        sum_next += next;
        sum_prev += prev;
    }

    var stdout = std.io.getStdOut();
    try stdout.writer().print("{d}\n", .{sum_next});
    try stdout.writer().print("{d}\n", .{sum_prev});
}
