XEN_TARGET_ARCH=x86_64
XEN_INCLUDE ?= /usr/include/xen

CFLAGS=-U __linux__ -U __FreeBSD__ -U __sun__ -D__MiniOS__ \
        -D__MiniOS__ -D__x86_64__ -D__XEN_INTERFACE_VERSION__=0x00030205 \
        -D__INSIDE_MINIOS__ -nostdinc -std=gnu99 -fno-stack-protector \
        -fstrict-aliasing -momit-leaf-frame-pointer -mfancy-math-387 \
	-I include -Wall

ifeq ($(XEN_TARGET_ARCH),x86_32)
ARCH_CFLAGS  := -m32 -march=i686
ARCH_LDFLAGS := -m elf_i386
ARCH_ASFLAGS := -m32
EXTRA_INC += -Iinclude/x86 -Iinclude/x86/x86_32
EXTRA_SRCS := arch/x86/x86_32.S
HEAD_OBJ := arch/x86/x86_32.o
endif

ifeq ($(XEN_TARGET_ARCH),x86_64)
ARCH_CFLAGS := -m64 -mno-red-zone -fno-reorder-blocks
ARCH_CFLAGS += -fno-asynchronous-unwind-tables
ARCH_ASFLAGS := -m64
ARCH_LDFLAGS := -m elf_x86_64
EXTRA_INC += -Iinclude/x86 -Iinclude/x86/x86_64
EXTRA_SRCS := arch/x86/x86_64.S
HEAD_OBJ := arch/x86/x86_64.o
endif

CFLAGS+=$(ARCH_CFLAGS) $(EXTRA_INC)
GCC_INSTALL = $(shell LANG=C $(CC) -print-search-dirs | sed -n -e 's/install: \(.*\)/\1/p')
EXTRA_INC += -I$(GCC_INSTALL)include
EXTRA_INC += -Iinclude/posix
OBJ_DIR=obj

# Sources here are all *.c *.S without $(XEN_TARGET_ARCH).S
# This is handled in $(HEAD_ARCH_OBJ)
ARCH_SRCS := $(wildcard arch/x86/*.c)

# The objects built from the sources.
ARCH_OBJS := $(patsubst %.c,%.o,$(ARCH_SRCS))

KERNEL_SRCS := $(wildcard *.c)
LIB_SRCS := $(wildcard lib/*.c)
LIB_SRCS := lib/printf.c lib/ctype.c lib/string.c
ALL_SRCS := $(KERNEL_SRCS) $(ARCH_SRCS) $(LIB_SRCS)

ALL_OBJS := $(patsubst %.c,%.o,$(ALL_SRCS))

%.o: %.S
	$(CC) -c $(CFLAGS) $(ARCH_ASFLAGS) -D__ASSEMBLY__ -o $@ $<

.PHONY: depend clean all
all: mini-os.gz
	@ :

mini-os: $(HEAD_OBJ) $(ALL_OBJS)
	$(LD) -d -nostdlib $(ARCH_LDFLAGS) -T arch/x86/minios-$(XEN_TARGET_ARCH).lds $^ -o $@

%.gz: %
	gzip -9 -c $< > $@

depend:
	ln -nsf $(XEN_INCLUDE) include/xen

clean:
	find . -name \*.o -exec rm -f {} \;
	rm -f mini-os mini-os.gz
