const std = @import("std");
const total_eggnog: u32 = 150;

fn solve_table(table: []u32, containers: []u32) !void {
    const table_width = total_eggnog + 1;
    const table_height = containers.len + 1;

    {
        // 1 way of making 0 eggnog using containers [0..num_containers]
        var num_containers: usize = 0;
        while (num_containers < table_height) : (num_containers += 1) {
            table[num_containers * table_width] = 1;
        }
    }

    {
        // 0 ways of making eggnog_amount>0 eggnog with no containers
        var eggnog_amount: usize = 1;
        while (eggnog_amount < table_width) : (eggnog_amount += 1) {
            table[eggnog_amount] = 0;
        }
    }

    {
        var num_containers: usize = 1;
        while (num_containers < table_height) : (num_containers += 1) {
            const this_container_size = containers[num_containers - 1];
            var eggnog_amount: usize = 1;
            while (eggnog_amount < table_width) : (eggnog_amount += 1) {
                const ways_without_using_this_container =
                    table[(num_containers - 1) * table_width + eggnog_amount];
                const ways_using_this_container =
                    if (this_container_size <= eggnog_amount)
                    table[(num_containers - 1) * table_width + (eggnog_amount - this_container_size)]
                else
                    0;
                table[num_containers * table_width + eggnog_amount] =
                    ways_without_using_this_container + ways_using_this_container;
            }
        }
    }
}

fn count_ways_by_num_containers(depth: usize, num_containers: usize, eggnog_amount: usize, table: []u32, containers: []u32, ways: *std.AutoHashMap(usize, u32)) void {
    const table_width = total_eggnog + 1;

    if (table[num_containers * table_width + eggnog_amount] == 0) {
        return;
    } else if (eggnog_amount == 0) {
        return ways.*.put(depth, ways.*.get(depth).? + 1) catch unreachable;
    }

    const this_container_size = containers[num_containers - 1];

    count_ways_by_num_containers(depth, num_containers - 1, eggnog_amount, table, containers, ways);

    if (this_container_size <= eggnog_amount)
        count_ways_by_num_containers(depth + 1, num_containers - 1, eggnog_amount - this_container_size, table, containers, ways);
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("inputs/day17.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var containers = std.ArrayList(u32).init(&gpa.allocator);
    defer containers.deinit();

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        try containers.append(try std.fmt.parseInt(u32, line, 10));
    }

    var table = std.ArrayList(u32).init(&gpa.allocator);
    defer table.deinit();
    try table.resize((total_eggnog + 1) * (containers.items.len + 1));
    try solve_table(table.items, containers.items);

    std.debug.print("{d}\n", .{table.items[table.items.len - 1]});

    var ways = std.AutoHashMap(usize, u32).init(&gpa.allocator);
    defer ways.deinit();

    {
        var i: usize = 0;
        while (i < containers.items.len + 1) : (i += 1) {
            try ways.put(i, 0);
        }
    }
    count_ways_by_num_containers(0, containers.items.len, total_eggnog, table.items, containers.items, &ways);

    {
        var i: usize = 0;
        while (i < containers.items.len + 1) : (i += 1) {
            if (ways.get(i).? > 0) {
                std.debug.print("{d}\n", .{ways.get(i).?});
                break;
            }
        }
    }
}
