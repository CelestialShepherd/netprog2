BOARD_ADDRESS ?= 192.168.0.8

ARCH ::= mips
CROSS_COMPILE ::= mipsel-oe-linux-musl-
KDIR ::= /usr/angtel-sdk/sysroots/mips32el-nf-oe-linux-musl/usr/src/kernel

O ::= $(KDIR)
SCRIPTS ::= $(O)/scripts/basic/fixdep

MOD ::= $(MOD_NAME)

ifneq ($(KERNELRELEASE),)

SRC ::= $(filter-out $(MOD).c, $(notdir $(wildcard $(M)/*.c)))
OBJ ::= $(SRC:%.c=%.o)

obj-m ::= $(MOD).o
$(MOD)-y ::= $(OBJ)

else

.PHONY: all clean install uninstall help

all: $(SCRIPTS)
	make -C $(KDIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
	M=$$PWD modules

$(SCRIPTS): $(SCRIPTS).c
	make -C $(KDIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
	O=$(O) scripts

clean:
	make -C $(KDIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
	M=$$PWD clean

install: all
	curl --user root: --upload-file $(MOD).ko ftp://$(BOARD_ADDRESS)

uninstall:
	curl --user root: --quote "DELE $(MOD).ko" ftp://$(BOARD_ADDRESS)

help:
	@echo available targets: all install uninstall clean

endif