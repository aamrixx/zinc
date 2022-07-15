pub const VgaColour = u8;
pub const COLOUR_BLACK = 0;
pub const COLOUR_BLUE = 1;
pub const COLOUR_GREEN = 2;
pub const COLOUR_CYAN = 3;
pub const COLOUR_RED = 4;
pub const COLOUR_MAGENTA = 5;
pub const COLOUR_BROWN = 6;
pub const COLOUR_LIGHT_GREY = 7;
pub const COLOUR_DARK_GREY = 8;
pub const COLOUR_LIGHT_BLUE = 9;
pub const COLOUR_LIGHT_GREEN = 10;
pub const COLOUR_LIGHT_CYAN = 11;
pub const COLOUR_LIGHT_RED = 12;
pub const COLOUR_LIGHT_MAGENTA = 13;
pub const COLOUR_LIGHT_BROWN = 14;
pub const COLOUR_WHITE = 15;

pub fn entryColour(fg: VgaColour, bg: VgaColour) u8 {
    return fg | (bg << 4);
}

pub fn entry(uc: u8, colour: u8) u16 {
    var c: u16 = colour;

    return uc | (c << 8);
}

const WIDTH = 80;
const HEIGHT = 25;

pub const terminal = struct {
    var row: usize = 0;
    var column: usize = 0;

    var colour = entryColour(COLOUR_WHITE, COLOUR_BLACK);

    const buffer = @intToPtr([*]volatile u16, 0xB8000);

    pub fn initialise() void {
        var y: usize = 0;
        while (y < HEIGHT) : (y += 1) {
            var x: usize = 0;
            while (x < WIDTH) : (x += 1) {
                putCharAt(' ', colour, x, y);
            }
        }
    }

    pub fn setColour(new_colour: u8) void {
        colour = new_colour;
    }

    pub fn putCharAt(c: u8, new_colour: u8, x: usize, y: usize) void {
        const index = y * WIDTH + x;
        buffer[index] = entry(c, new_colour);
    }

    pub fn putChar(c: u8) void {
        putCharAt(c, colour, column, row);
        column += 1;
        if (column == WIDTH) {
            column = 0;
            row += 1;
            if (row == HEIGHT)
                row = 0;
        }   
    }

    pub fn newLine() void {
        row += 1;
        column = 0;
        if (row == HEIGHT)
                row = 0;
    }

    pub fn write(data: []const u8) void {
        for (data) |c|
            putChar(c);
    }
};
