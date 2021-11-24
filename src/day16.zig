const std = @import("std");
const num_aunts: u32 = 500;

pub fn main() !void {
    const file =
        try std.fs.cwd().openFile("inputs/day16.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // var vs = ArrayList(V5).init(&gpa.allocator);
    // defer vs.deinit();

    var aunts: [num_aunts]std.StringHashMap(u32) = undefined;
    _ = aunts;

    var line_num: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| : (line_num += 1) {
        var pos: usize = 0;
        while (line[pos] != ':') : (pos += 1) {}
        pos += 2; // ": "
        var line_content = line[pos..];

        aunts[line_num] = std.StringHashMap(u32).init(&gpa.allocator);

        var properties = std.mem.tokenize(u8, line_content, ",");
        while (properties.next()) |property| {
            var tokens = std.mem.tokenize(u8, property, ": ");
            const propertyName = tokens.next().?;

            const newPropertyName = try gpa.allocator.alloc(u8, propertyName.len);
            for (propertyName) |c, i| newPropertyName[i] = c;

            std.debug.print("{s}|\n", .{newPropertyName});
            std.debug.print("{d}\n", .{line_num});
            const propertyValue = try std.fmt.parseInt(u32, tokens.next().?, 10);
            try aunts[line_num].put(newPropertyName, propertyValue);
            std.debug.print("{any}\n", .{aunts[line_num].get(newPropertyName)});
            std.debug.print("{any}\n", .{aunts[line_num].get("children")});
        }
    }

    std.debug.print("{any}\n", .{aunts[0]});
    std.debug.print("aunts[0].get(\"children\"): {any}\n", .{aunts[0].get("children")});

    var i: usize = 0;
    var answer: ?usize = null;
    while (i < num_aunts) : (i += 1) {
        // std.debug.print("{any}\n", .{aunts[i].get("children")});
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
        answer = i;
    }

    std.debug.print("{d}\n", .{answer});

    i = 0;
    while (i < num_aunts) : (i += 1) {
        aunts[i].deinit();
    }
}
