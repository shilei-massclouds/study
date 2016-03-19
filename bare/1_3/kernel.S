# 16bit mode
.code16

#define INIT_STACK_ADDR         0x2000

.global _start

.text

_start:

# Clear DS and ES to Zero
    xor     %ax, %ax
    mov     %ax, %ds
    mov     %ax, %es
    mov     %ax, %ss

# Init stack top as 0x2000
	mov     $INIT_STACK_ADDR, %sp

# Display information
    call    print

# End of this program
end:
    jmp     end

# Define a function print
print:
# Get Cursor position: DH - row, DL - column
    xorb    %bh, %bh            # BH - page number
    movb    $0x03, %ah          # AH - 0x03, get cursor position and size
    int     $0x10               # DH - return row, DL - return column

# Display info, total size 24 in character
    mov     $24, %cx            # CX - 24, characters numbers to write
    mov     $0x000A, %bx        # BH - page number; BL - attribute 7 (normal)
    mov     $info, %bp          # ES:BP - string base address
    mov     $0x1301, %ax        # AH - 0x13, write string; AL[1:0] - 01, update curso after writing
    int     $0x10
    ret                         # Function return

info:
    .byte   13, 10
    .ascii  "mcKernel startup ... "
