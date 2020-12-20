// Imports
const std = @import("std");
const expect = @import("std").testing.expect;

// ************************
// *      Constants       *
// ************************
const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

const Stuff = struct {
    x: i32,
    y: i32,

    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

const Vec3 = struct {
    x: f32, y: f32, z: f32
};

const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next,
};

const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

const Vec4 = struct {
    x: f32, y: f32, z: f32 = 0, w: f32 = undefined
};

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{OutOfMemory};

const Direction = enum { north, south, east, west };

const Value = enum(u2) { zero, one, two };

// ********************
// *    Variables     *
// ********************
var problems: u32 = 98;

// *******************
// *     Functions   *
// *******************
fn addFive(x: u32) u32 {
    return x + 5;
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFunction();
}

fn createFile() !void {
    return error.AccessDenied;
}

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        else => unreachable,
    };
}

fn increment(num: *u8) void {
    num.* += 1;
}

fn total(values: []const u8) usize {
    var count: usize = 0;
    for (values) |v| count += v;
    return count;
}

// ******************
// *     Tests      *
// ******************
test "struct usage" {
    const my_vector = Vec3{
        .x = 0,
        .y = 100,
        .z = 50,
    };
}

test "struct defaults" {
    const my_vector = Vec4{
        .x = 25,
        .y = -50,
    };
}

test "switch" {
    var x: i8 = 10;

    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            x = @divExact(x, 10);
        },
        else => {},
    }
    expect(x == 1);
}

test "switch as expression" {
    var x: i8 = 10;

    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    expect(x == 1);
}

test "function" {
    const y = addFive(0);
    expect(@TypeOf(y) == u32);
    expect(y == 5);
}

test "recursion" {
    const x = fibonacci(10);
    expect(x == 55);
}

test "defer" {
    var x: i16 = 5;
    {
        defer x += 2;
        expect(x == 5);
    }
    expect(x == 7);
}

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    expect(err == FileOpenError.OutOfMemory);
}

test "error union" {
    const maybe_error: AllocationError!u16 = 10;
    const no_error = maybe_error catch 0;

    expect(@TypeOf(no_error) == u16);
    expect(no_error == 10);
}

test "returning an error" {
    failingFunction() catch |err| {
        expect(err == error.Oops);
        return;
    };
}

test "try" {
    var v = failFn() catch |err| {
        expect(err == error.Oops);
        return;
    };
    expect(v == 12); // never executes
}

test "errdefer" {
    failFnCounter() catch |err| {
        expect(err == error.Oops);
        expect(problems == 99);
        return;
    };
}

test "inferred error set" {
    // type coercion successfully occurs
    const x: error{AccessDenied}!void = createFile();
}

test "unreachable code" {
    expect(asciiToUpper('a') == 'A');
    expect(asciiToUpper('A') == 'A');
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    expect(x == 2);
}

test "usize" {
    expect(@sizeOf(usize) == @sizeOf(*u8));
    expect(@sizeOf(isize) == @sizeOf(*i8));
}

test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(total(slice) == 6);
}

test "slices2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(@TypeOf(slice) == *const [3]u8);
}

test "slices3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    var slice = array[0..];
}

test "enum ordinal value" {
    expect(@enumToInt(Value.zero) == 0);
    expect(@enumToInt(Value.one) == 1);
    expect(@enumToInt(Value.two) == 2);
}

test "set enum ordinal value" {
    expect(@enumToInt(Value2.hundred) == 100);
    expect(@enumToInt(Value2.thousand) == 1000);
    expect(@enumToInt(Value2.million) == 1000000);
    expect(@enumToInt(Value2.next) == 1000001);
}

test "enum method" {
    expect(Suit.spades.isClubs() == Suit.isClubs(.spades));
}

test "hmm" {
    Mode.count += 1;
    expect(Mode.count == 1);
}

test "automatic dereference" {
    var thing = Stuff{ .x = 10, .y = 20 };
    thing.swap();
    expect(thing.x == 20);
    expect(thing.y == 10);
}
