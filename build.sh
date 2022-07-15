#!/bin/bash

zig build-exe src/main.zig -target i386-freestanding -T linker.ld
qemu-system-i386 -serial stdio -kernel main
