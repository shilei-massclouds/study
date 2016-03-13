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

Image: bootsect
	cat bootsect > $@
	sync
	@wc	-c $@

bootsect.s: bootsect.S
	${CPP} -traditional -o $@ $<

bootsect: bootsect.s
	${AS} -a -o bootsect.o $< > bootsect.map
	${LD} --oformat binary -Ttext 0x0 -o $@ bootsect.o
	-rm $<
	@wc -c $@

clean:
	-rm -f *.map *.o bootsect Image
