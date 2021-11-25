const std = @import("std");
const num_aunts: u32 = 500;

fn solve1(aunts: [num_aunts]std.StringHashMap(u32)) ?usize {
    var i: usize = 0;
    while (i < num_aunts) : (i += 1) {
        if (aunts[i].get("children") orelse 3 != 3) continue;
        if (aunts[i].get("cats") orelse 7 != 7) continue;
        if (aunts[i].get("samoyeds") orelse 2 != 2) continue;
        if (aunts[i].get("pomeranians") orelse 3 != 3) continue;
        if (aunts[i].get("akitas") orelse 0 != 0) continue;
        if (aunts[i].get("vizslas") orelse 0 != 0) continue;
        if (aunts[i].get("goldfish") orelse 5 != 5) continue;
        if (aunts[i].get("trees") orelse 3 != 3) continue;
        if (aunts[i].get("cars") orelse 2 != 2) continue;
        if (aunts[i].get("perfumes") orelse 1 != 1) continue;
        return i + 1;
    }
    return null;
}

fn solve2(aunts: [num_aunts]std.StringHashMap(u32)) ?usize {
    var i: usize = 0;
    while (i < num_aunts) : (i += 1) {
        if (aunts[i].get("children") orelse 3 != 3) continue;
        if (aunts[i].get("cats") orelse 8 <= 7) continue;
        if (aunts[i].get("samoyeds") orelse 2 != 2) continue;
        if (aunts[i].get("pomeranians") orelse 2 >= 3) continue;
        if (aunts[i].get("akitas") orelse 0 != 0) continue;
        if (aunts[i].get("vizslas") orelse 0 != 0) continue;
        if (aunts[i].get("goldfish") orelse 4 >= 5) continue;
        if (aunts[i].get("trees") orelse 4 <= 3) continue;
        if (aunts[i].get("cars") orelse 2 != 2) continue;
        if (aunts[i].get("perfumes") orelse 1 != 1) continue;
        return i + 1;
    }
    return null;
}
pub fn main() !void {
    const file =
        try std.fs.cwd().openFile("inputs/day16.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();

    var aunts: [num_aunts]std.StringHashMap(u32) = undefined;
    // We need to allocate memory for property names (to avoid pointing to the
    // reader buffer, which won't be valid), so store the names in a map/set to
    // only allocate each of them once
    var propertyNames = std.StringHashMap(void).init(&arena.allocator);

    var line_num: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| : (line_num += 1) {
        var pos: usize = 0;
        // Skip everything up to the first colon
        while (line[pos] != ':') : (pos += 1) {}
        pos += 2; // Skip ": "
        var line_content = line[pos..];

        aunts[line_num] = std.StringHashMap(u32).init(&arena.allocator);

        var properties = std.mem.tokenize(u8, line_content, ",");
        while (properties.next()) |property| {
            var tokens = std.mem.tokenize(u8, property, ": ");
            const tempPropertyName = tokens.next().?;

            // If it's a property we haven't seen yet, allocate memory to store
            // the name
            if (!propertyNames.contains(tempPropertyName)) {
                const newPropertyName = try arena.allocator.alloc(u8, tempPropertyName.len);
                for (tempPropertyName) |c, i| newPropertyName[i] = c;
                try propertyNames.put(newPropertyName, undefined);
            }

            const propertyName = propertyNames.getKey(tempPropertyName).?;
            const propertyValue = try std.fmt.parseInt(u32, tokens.next().?, 10);
            try aunts[line_num].put(propertyName, propertyValue);
        }
    }

    std.debug.print("{d}\n", .{solve1(aunts)});
    std.debug.print("{d}\n", .{solve2(aunts)});
}
