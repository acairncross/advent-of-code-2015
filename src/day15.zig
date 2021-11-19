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

fn sum(v: []i64) i64 {
    var total: i64 = 0;
    for (v) |x| {
        total += x;
    }
    return total;
}

fn do_score(ingredients: []V5, teaspoons: []i64) i64 {
    var v: V5 = [_]i64{0} ** 5;
    var i: usize = 0;
    while (i < teaspoons.len) : (i += 1) {
        v = addV5(v, scaleV5(teaspoons[i], ingredients[i]));
    }
    return product(clampV5(0, v)[0..4]);
}

fn solve(ingredients: []V5, teaspoons: []i64, index: usize) i64 {
    var used_teaspoons: i64 = sum(teaspoons[0..index]);
    if (index == ingredients.len) {
        return do_score(ingredients, teaspoons);
    } else {
        var max_score: i64 = 0;
        teaspoons[index] = 0;
        while (teaspoons[index] + used_teaspoons <= num_teaspoons) : (teaspoons[index] += 1) {
            max_score = @maximum(max_score, solve(ingredients, teaspoons, index + 1));
        }
        return max_score;
    }
}

pub fn main() !void {
    const file =
        try std.fs.cwd().openFile("inputs/day15.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    _ = reader;
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();

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

    var teaspoons = ArrayList(i64).init(arena_allocator);
    try teaspoons.resize(vs.items.len);
    defer teaspoons.deinit();
    std.debug.print("{d}\n", .{solve(vs.items, teaspoons.items, 0)});
}
