const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const file =
        try std.fs.cwd().openFile("inputs/day01.txt", .{ .read = true });
    defer file.close();

    const input = try file.readToEndAlloc(allocator, 10000);

    var count: i32 = 0;
    var pos: i32 = 1;
    var basement_pos: i32 = 0;
    for (input) |c| {
        if (c == '(') {
            count += 1;
        } else {
            count -= 1;
        }
        if (count < 0 and basement_pos == 0) {
            basement_pos = pos;
        }
        pos += 1;
    }

    std.debug.print("{d}\n", .{count});
    std.debug.print("{d}\n", .{basement_pos});
}
