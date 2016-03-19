#
# Makefile: Top 
#

AS=as
CC=gcc
LD=ld
OBJCOPY=objcopy
CPP=cpp -nostdinc

CFLAGS=-g -Wall -O -fstrength-reduce -fomit-frame-pointer -nostdinc -Iinclude -fno-stack-protector -fno-builtin
LDFLAGS=-M -x

all: clean Image

Image: bootsect kernel
	cat bootsect kernel > $@
	sync
	@wc	-c $@

%.s: %.S
	${CPP} -traditional -o $@ $<

bootsect: bootsect.s
	${AS} -a -o bootsect.o $< > bootsect.map
	${LD} --oformat binary -Ttext 0x7C00 -o $@ bootsect.o
	-rm $<
	@wc -c $@

kernel: kernel.s
	${AS} -a -o kernel.o $< > kernel.map
	${LD} --oformat binary -Ttext 0x8000 -o $@ kernel.o
	-rm $<
	@wc -c $@

clean:
	-rm -f *.map *.o bootsect kernel Image
