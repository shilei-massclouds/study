# 16bit mode
.code16

.global _start

.text

BOOTSEG     = 0x07C0            # original address of boot-sector

ROOT_DEV    = 0
SWAP_DEV    = 0

_start:

    mov     $BOOTSEG, %ax   # BOOTSEG 0x7C0
    mov     %ax, %ds
    mov     %ax, %es

# Display information about "CR+LF+Hello, world!", total size 15 in character
    mov     $15, %cx             # CX - 15, characters numbers to write
    mov     $0x0007, %bx        # BH - page number; BL - attribute 7 (normal)
    mov     $info, %bp          # ES:BP - string base address
    mov     $0x1301, %ax        # AH - 0x13, write string; AL[1:0] - 01, update curso after writing
    int     $0x10

info:
    .byte   13, 10
    .ascii  "Hello, world!"

.org    506
swap_dev:
    .word   SWAP_DEV
root_dev:
    .word   ROOT_DEV

boot_flag:
    .word   0xAA55

