const builtin = @import("builtin");


const io = @import("io.zig");
const log = @import("log.zig");
// dev
const serial = @import("dev/serial.zig");
const vga = @import("dev/vga.zig");
// sys
const gdt = @import("sys/gdt.zig");


const MultiBoot = packed struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    @call(.{ .stack = stack_bytes_slice }, kmain, .{});

    while (true) {}
}

fn kmain() void {
    gdt.initialise();
    vga.terminal.initialise();
    
    log.log(serial.initialise(), "Serial Port");
}
