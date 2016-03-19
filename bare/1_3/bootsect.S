# 16bit mode
.code16

#define INIT_STACK_ADDR         0x2000

#define BOOT_KERNEL_SEG         0x800
#define BOOT_KERNEL_ADDR        (BOOT_KERNEL_SEG << 4)

#define MSG(x)	push %si; movw $x, %si; call print; pop %si

.global _start

.text

_start:

# Be sure that DS/ES/SS clear to Zero
    xor     %ax, %ax
    mov     %ax, %ds
    mov     %ax, %es
    mov     %ax, %ss

# Init stack top as 0x2000
	mov     $INIT_STACK_ADDR, %sp

# Display startup information
    MSG(msg0)

# First save DX (because INT 13H - 41H will modify it!)
	pushw	%dx

# Set %si to the LBA parameters table address
	movw	$params_table, %si

# INT 13H(41H): Check if LBA is supported?
	movb	$0x41, %ah
	movw	$0x55aa, %bx
	int     $0x13

# Recover DX
	popw	%dx

# Use CHS if fails (Now ignore! You can do it!)
    # Condition-1: Carry bit?
	jc	    exit
    # Condition-2: BX value?
	cmpw	$0xaa55, %bx
	jne     exit
    # Condition-3: CX LSB?
	andw	$1, %cx
	jz	    exit

    MSG(msg1)

lba_mode:
# Set the mode(byte) to 1: it means lba_mode!!!
    movw    $1, %ax
	movb	%al, -1(%si)

# 00h: (byte) size of params table(10h)
# 01h: (byte) reserved(0)
	movw	$0x0010, (%si)

# 02h: (word) number of blocks to transfer
# Just only 1 block! (now AX value is 1)
	movw	%ax, 2(%si)

# 04h: (word) target buffer offset
# Just set to 0
	xorw	%ax, %ax
	movw	%ax, 4(%si)

# 06h: (word) segment of buffer(SEG)
	movw	$BOOT_KERNEL_SEG, 6(%si)

# 08h: (qword) start block number
# Just NO.1 sector which followed MBR sector(No.0)
	movl	kernel_sector, %ebx
	movl	%ebx, 8(%si)
	movl	kernel_sector + 4, %ebx
	movl	%ebx, 12(%si)

# BIOS call "INT 0x13 Function 0x42" to read sectors from disk into memory
#   %ah = 0x42
#   %dl = drive number
#   %ds:%si = segment:offset of parameters table address
#   Return:
#   %al = 0x0 on success; err code on failure
	movb	$0x42, %ah
	int     $0x13

# Exit when LBA read failed!
	jc	    exit

    MSG(msg2)

    MSG(msg3)
# boot kernel
	jmp     *(kernel_address)

exit:

# End of this program
end:
    jmp     end


# print: write the string pointed to by %si
# WARNING: trashes %si, %ax, and %bx
# Use BIOS "int 10H Function 0Eh" to write character in teletype mode
#   %ah = 0xe	%al = character
#   %bh = page	%bl = foreground color (graphics modes)
1:
    xorb    %bh, %bh
	movb	$0x0E, %ah
	int     $0x10		/* display a byte */
print:
	lodsb
	cmpb	$0, %al
	jne     1b          /* if not end of string, jmp to display */
	ret

msg0:
    .asciz  "\r\nmcGrub startup ...\r\n"

msg1:
    .asciz  "load kernel ...\r\n"

msg2:
    .asciz  "load kernel ok!\r\n"

msg3:
    .asciz  "prepare jump to kernel ...\r\n"

.org    464
# Kernel sector seqence number 1, just followed MBR sector 0
kernel_sector:
	.long	1, 0
kernel_address:
	.word	BOOT_KERNEL_ADDR

# Mode: LBA or CHS
# Only high byte valid! low byte ignore!
mode:
	.word	0

# Reserve space for LBA parameters table (size is 10h bytes)
params_table:

# Boot sector flag!
.org    510
boot_flag:
    .word   0xAA55
