const std = @import("std");
const ArrayList = std.ArrayList;

const V5 = [5]i64;
const num_teaspoons: u32 = 100;

fn addV5(u: V5, v: V5) V5 {
    return V5{
        u[0] + v[0],
        u[1] + v[1],
        u[2] + v[2],
        u[3] + v[3],
        u[4] + v[4],
    };
}

fn scaleV5(c: i64, v: V5) V5 {
    return V5{ v[0] * c, v[1] * c, v[2] * c, v[3] * c, v[4] * c };
}

fn clampV5(lo: i64, v: V5) V5 {
    return V5{ @maximum(lo, v[0]), @maximum(lo, v[1]), @maximum(lo, v[2]), @maximum(lo, v[3]), @maximum(lo, v[4]) };
}

fn product(v: []i64) i64 {
    var total: i64 = 1;
    for (v) |x| {
        total *= x;
    }
    return total;
}

pub fn main() !void {
    const file =
        try std.fs.cwd().openFile("inputs/day15.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    _ = reader;
    var buffer: [1024]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    arena.deinit();
    var arena_allocator = &arena.allocator;
    var vs = ArrayList(V5).init(arena_allocator);
    defer vs.deinit();
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, ":");
        _ = tokens.next(); // "Ingredient: "
        // Split in to property-value tokens
        tokens = std.mem.tokenize(u8, tokens.next().?, ",");

        var v: V5 = undefined;
        var index: u32 = 0;
        while (tokens.next()) |token| : (index += 1) {
            // Split property and value
            var tokens2 = std.mem.tokenize(u8, token, " ");
            _ = tokens2.next(); // property
            v[index] = try std.fmt.parseInt(i64, tokens2.next().?, 10);
        }

        try vs.append(v);
    }

    for (vs.items) |v| {
        std.debug.print("{any}\n", .{addV5(v, v)});
    }

    var best_score: i64 = 0;
    var i: usize = 0;
    while (i < num_teaspoons) : (i += 1) {
        const w = scaleV5(@intCast(i64, i), vs.items[0]);
        var j: usize = 0;
        while (j < num_teaspoons - i) : (j += 1) {
            const x = addV5(scaleV5(@intCast(i64, j), vs.items[1]), w);
            var k: usize = 0;
            while (k < num_teaspoons - i - j) : (k += 1) {
                const y = addV5(scaleV5(@intCast(i64, k), vs.items[2]), x);
                const l: usize = num_teaspoons - i - j - k;
                const z: V5 = addV5(scaleV5(@intCast(i64, l), vs.items[3]), y);

                // Product of only the first 4 values
                const score = product(clampV5(0, z)[0..4]);
                if (score > best_score) {
                    std.debug.print("{d}\n", .{score});
                    std.debug.print("{d} {d} {d} {d}\n", .{ i, j, k, l });
                    best_score = score;
                }
            }
        }
    }
}
