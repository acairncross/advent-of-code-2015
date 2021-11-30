const std = @import("std");
const ArrayList = std.ArrayList;
const Grid = ArrayList(ArrayList(u8));

const Coord = struct { i: i32, j: i32 };

const neighbor_relative_coords = [_]Coord{
    Coord{ .i = -1, .j = -1 },
    Coord{ .i = 0, .j = -1 },
    Coord{ .i = 1, .j = -1 },
    Coord{ .i = -1, .j = 0 },
    Coord{ .i = 1, .j = 0 },
    Coord{ .i = -1, .j = 1 },
    Coord{ .i = 0, .j = 1 },
    Coord{ .i = 1, .j = 1 },
};

// Fill next_grid with the next state of grid
fn step(grid: ArrayList(ArrayList(u8)), next_grid: ArrayList(ArrayList(u8))) void {
    const grid_width = grid.items[0].items.len;
    const grid_height = grid.items.len;

    var i: usize = 0;
    while (i < grid_height) : (i += 1) {
        var j: usize = 0;
        while (j < grid_width) : (j += 1) {
            var num_neighbors_on: u32 = 0;
            for (neighbor_relative_coords) |coord| {
                const ii: i32 = @intCast(i32, i) + coord.i;
                const jj: i32 = @intCast(i32, j) + coord.j;
                if (ii >= 0 and ii < grid_height and jj >= 0 and jj < grid_width) {
                    if (grid.items[@intCast(usize, ii)].items[@intCast(usize, jj)] == '#') {
                        num_neighbors_on += 1;
                    }
                }
            }

            if (grid.items[i].items[j] == '#') {
                if (num_neighbors_on == 2 or num_neighbors_on == 3) {
                    next_grid.items[i].items[j] = '#';
                } else {
                    next_grid.items[i].items[j] = '.';
                }
            } else {
                if (num_neighbors_on == 3) {
                    next_grid.items[i].items[j] = '#';
                } else {
                    next_grid.items[i].items[j] = '.';
                }
            }
        }
    }
}

fn count_lights(grid: ArrayList(ArrayList(u8))) u32 {
    var num_lights: u32 = 0;
    for (grid.items) |row| {
        for (row.items) |c| {
            if (c == '#') {
                num_lights += 1;
            }
        }
    }
    return num_lights;
}

fn clone_grid(orig_grid: ArrayList(ArrayList(u8)), arena_allocator: *std.mem.Allocator) !ArrayList(ArrayList(u8)) {
    var grid = ArrayList(ArrayList(u8)).init(arena_allocator);
    for (orig_grid.items) |orig_row| {
        var row = ArrayList(u8).init(arena_allocator);
        for (orig_row.items) |c| {
            try row.append(c);
        }
        try grid.append(row);
    }
    return grid;
}

fn fix_corners(grid: ArrayList(ArrayList(u8))) void {
    const grid_width = grid.items[0].items.len;
    const grid_height = grid.items.len;
    grid.items[0].items[0] = '#';
    grid.items[0].items[grid_width - 1] = '#';
    grid.items[grid_height - 1].items[0] = '#';
    grid.items[grid_height - 1].items[grid_width - 1] = '#';
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("inputs/day18.txt", .{ .read = true });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader()).reader();
    var buffer: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();

    var orig_grid = ArrayList(ArrayList(u8)).init(&arena.allocator);

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var row = ArrayList(u8).init(&arena.allocator);
        for (line) |c| {
            try row.append(c);
        }
        try orig_grid.append(row);
    }

    var grid = try clone_grid(orig_grid, &arena.allocator);
    var next_grid = try clone_grid(orig_grid, &arena.allocator);
    {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            step(grid, next_grid);
            var tmp_grid = grid;
            grid = next_grid;
            next_grid = tmp_grid;
        }
    }
    std.debug.print("{d}\n", .{count_lights(grid)});

    grid = try clone_grid(orig_grid, &arena.allocator);
    fix_corners(grid);
    {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            step(grid, next_grid);
            fix_corners(next_grid);
            var tmp_grid = grid;
            grid = next_grid;
            next_grid = tmp_grid;
        }
    }
    std.debug.print("{d}\n", .{count_lights(grid)});
}
