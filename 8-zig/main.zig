const std = @import("std");

const Row = std.BoundedArray(u8, 64);
const Location = struct { r: isize, c: isize };
const Locations = std.ArrayList(Location);
const Frequencies = std.AutoHashMap(u8, Locations);

pub fn main() !void {
    const writer = std.io.getStdOut().writer();
    const reader = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    var grid = std.ArrayList(Row).init(allocator);
    var frequencies = Frequencies.init(allocator);

    var buf = try Row.init(64);
    while (try reader.readUntilDelimiterOrEof(&buf.buffer, '\n')) |line| {
        const row = try Row.fromSlice(line);
        const r = grid.items.len;
        for (line, 0..) |cell, c| {
            if (cell == '.') {
                continue;
            }
            const locations = try frequencies.getOrPut(cell);
            if (!locations.found_existing) {
                locations.value_ptr.* = Locations.init(allocator);
            }
            try locations.value_ptr.*.append(Location{
                .r = @intCast(r),
                .c = @intCast(c),
            });
        }
        try grid.append(row);
    }

    const rows = grid.items.len;
    const cols = grid.items[0].len;

    const ans1 = try puzzle1(rows, cols, frequencies, allocator);
    const ans2 = try puzzle2(rows, cols, frequencies, allocator);

    try writer.print("Puzzle 1: {}\nPuzzle 2: {}\n", .{ ans1, ans2 });
}

fn puzzle1(rows: usize, cols: usize, frequencies: Frequencies, allocator: std.mem.Allocator) !u32 {
    var seen = std.AutoHashMap(Location, bool).init(allocator);
    defer seen.deinit();

    var fiterator = frequencies.valueIterator();
    while (fiterator.next()) |locs| {
        for (locs.items) |loc1| {
            for (locs.items) |loc2| {
                if (loc1.r == loc2.r and loc1.c == loc2.c) {
                    continue;
                }

                const target = Location{
                    .r = loc1.r + 2 * (loc2.r - loc1.r),
                    .c = loc1.c + 2 * (loc2.c - loc1.c),
                };

                if (0 <= target.r and target.r < rows and 0 <= target.c and target.c < cols) {
                    try seen.put(target, true);
                }
            }
        }
    }

    return seen.count();
}

fn puzzle2(rows: usize, cols: usize, frequencies: Frequencies, allocator: std.mem.Allocator) !u32 {
    var seen = std.AutoHashMap(Location, bool).init(allocator);
    defer seen.deinit();

    var fiterator = frequencies.valueIterator();
    while (fiterator.next()) |locs| {
        for (locs.items) |loc1| {
            for (locs.items) |loc2| {
                if (loc1.r == loc2.r and loc1.c == loc2.c) {
                    continue;
                }

                const dr = loc2.r - loc1.r;
                const dc = loc2.c - loc1.c;
                var tr = loc1.r;
                var tc = loc1.c;
                while (0 <= tr and tr < rows and 0 <= tc and tc < cols) : ({
                    tr += dr;
                    tc += dc;
                }) {
                    const target = Location{ .r = tr, .c = tc };
                    try seen.put(target, true);
                }
            }
        }
    }

    return seen.count();
}
