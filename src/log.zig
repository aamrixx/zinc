const vga = @import("dev/vga.zig");

pub fn log(status: usize, name: []const u8) void {
    if (status == 0) {
        vga.terminal.write("< ");
        vga.terminal.setColour(vga.COLOUR_GREEN);
        vga.terminal.write("OK ");
        vga.terminal.setColour(vga.COLOUR_WHITE);
        vga.terminal.write("> ");
        vga.terminal.write(name);
        vga.terminal.newLine();
    } else {
        vga.terminal.write("< ERR > ");
        vga.terminal.write(name);
        vga.terminal.write("\n");
    }
}