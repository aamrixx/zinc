// GDT segment selectors.
pub const KERNEL_CODE = 0x08;
pub const KERNEL_DATA = 0x10;
pub const USER_CODE = 0x18;
pub const USER_DATA = 0x20;

// Privilege level of segment selector.
pub const KERNEL_RPL = 0b00;
pub const USER_RPL = 0b11;

// Access byte values.
const KERNEL = 0x90;
const USER = 0xF0;
const CODE = 0x0A;
const DATA = 0x02;

// Segment flags.
const PROTECTED = (1 << 2);
const BLOCKS_4K = (1 << 3);

// Structure representing an entry in the GDT.
const GDTEntry = packed struct {
    limit_low:   u16,
    base_low:    u16,
    base_mid:    u8,
    access:      u8,
    limit_high:  u4,
    flags:       u4,
    base_high:   u8,
};

// GDT descriptor register.
const GDTRegister = packed struct {
    limit:  u16,
    base:   *const GDTEntry,
};

fn makeEntry(base: usize, limit: usize, access: u8, flags: u4) GDTEntry {
    return GDTEntry{
        .limit_low   = @truncate(u16, limit),
        .base_low    = @truncate(u16, base),
        .base_mid    = @truncate(u8, base >> 16),
        .access      = @truncate(u8, access),
        .limit_high  = @truncate(u4, limit >> 16),
        .flags       = @truncate(u4, flags),
        .base_high   = @truncate(u8, base >> 24),
    };
}

// Fill in the GDT.
var gdt align(4) = [_]GDTEntry{
    makeEntry(0, 0, 0, 0),
    makeEntry(0, 0xFFFFF, KERNEL | CODE, PROTECTED | BLOCKS_4K),
    makeEntry(0, 0xFFFFF, KERNEL | DATA, PROTECTED | BLOCKS_4K),
    makeEntry(0, 0xFFFFF, USER | CODE, PROTECTED | BLOCKS_4K),
    makeEntry(0, 0xFFFFF, USER | DATA, PROTECTED | BLOCKS_4K),
};

// GDT descriptor register pointing at the GDT.
var gdtr = GDTRegister{
    .limit  = @as(u16, @sizeOf(@TypeOf(gdt))),
    .base   = &gdt[0],
};

comptime {
    asm (
        \\ .type loadGDT, @function
        \\ .global loadGDT
        \\ loadGDT:
        \\   mov +4(%esp), %eax
        \\   lgdt (%eax)
        \\   mov $0x10, %ax
        \\   mov %ax, %ds
        \\   mov %ax, %es
        \\   mov %ax, %fs
        \\   mov %ax, %gs
        \\   mov %ax, %ss
        \\   ljmp $0x08, $1f
        \\   1:  ret
    );
}
extern fn loadGDT(gdtr: *const GDTRegister) void;

pub fn initialise() void {
    loadGDT(&gdtr);
}
