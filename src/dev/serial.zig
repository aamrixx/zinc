const io = @import("../io.zig");

pub const PORT_1 =  0x3f8;

pub fn initialise() usize {
    io.outb(PORT_1 + 1, 0x00);
    io.outb(PORT_1 + 3, 0x80);
    io.outb(PORT_1 + 0, 0x03);
    io.outb(PORT_1 + 1, 0x00);
    io.outb(PORT_1 + 3, 0x03);
    io.outb(PORT_1 + 2, 0xC7);
    io.outb(PORT_1 + 4, 0x0B);
    io.outb(PORT_1 + 4, 0x1E);
    io.outb(PORT_1 + 0, 0xAE);

    if (io.inb(PORT_1 + 0) != 0xAE) {
        return 1;
    }

    io.outb(PORT_1 + 4, 0x0F);
    return 0;
}

pub fn write(str: []const u8) void {
    while ((io.inb(PORT_1 + 5) & 0x20) == 0) {}

    for (str) |c| 
        io.outb(PORT_1, c);
}