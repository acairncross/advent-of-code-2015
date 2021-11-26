const std = @import("std");
const total_eggnog: u32 = 150;

fn solve1(container_sizes: []u32, allocator: *std.mem.Allocator) !u32 {
    var arr = std.ArrayList([total_eggnog + 1]u32).init(allocator);
    defer arr.deinit();
    try arr.resize(container_sizes.len + 1);

    {
        // 1 way of making 0 eggnog using containers [0..i]
        var i: usize = 0;
        while (i < arr.items.len) : (i += 1) {
            arr.items[i][0] = 1;
        }
    }

    {
        // 0 ways of making j>0 eggnog with no containers
        var j: usize = 1;
        while (j < arr.items[0].len) : (j += 1) {
            arr.items[0][j] = 0;
        }
    }

    {
        var i: usize = 1;
        while (i < arr.items.len) : (i += 1) {
            const this_container_size = container_sizes[i - 1];
            var j: usize = 1;
            while (j < arr.items[i].len) : (j += 1) {
                const ways_without_using_this_container = arr.items[i - 1][j];
                const ways_using_this_container = if (this_container_size <= j) arr.items[i - 1][j - this_container_size] else 0;
                arr.items[i][j] = ways_without_using_this_container + ways_using_this_container;
            }
        }
    }

    return arr.items[container_sizes.len][total_eggnog];
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("inputs/day17.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var container_sizes = std.ArrayList(u32).init(&gpa.allocator);
    defer container_sizes.deinit();

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        try container_sizes.append(try std.fmt.parseInt(u32, line, 10));
    }

    std.debug.print("{d}\n", .{try solve1(container_sizes.items, &gpa.allocator)});
}
