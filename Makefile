# ==========================================================================
#  GroundClean 1.1.3 - MinGW-w64 build.
#
#  make            release, host arch
#  make arch=32    release, i686
#  make arch=64    release, x86_64
#  make debug      -O0 -g
#  make clean
# ==========================================================================

CC      ?= gcc
WINDRES ?= windres

BIN      := GroundClean.exe
BUILD    := build
TARGET   := $(BUILD)/$(BIN)

ARCHFLAG := $(if $(arch),-m$(arch),)

CPPFLAGS := -Iinclude -DWIN32_LEAN_AND_MEAN -D_WIN32_WINNT=0x0601 -DWINVER=0x0601
CFLAGS   := -std=gnu99 -Wall -Wextra -Wshadow -Wstrict-prototypes \
            -Wmissing-prototypes -fno-strict-aliasing $(ARCHFLAG)
LDFLAGS  := -Wl,--subsystem,console -Wl,--nxcompat -Wl,--dynamicbase
LIBS     := -lshlwapi -lshell32 -ladvapi32 -lole32 -loleaut32 -luuid -luser32

SRCS := src/main.c src/gc_common.c src/gc_log.c src/gc_priv.c src/gc_pe.c \
        src/gc_proc.c src/gc_quarantine.c src/gc_remediate.c src/gc_reg.c \
        src/gc_startup.c src/gc_autorun.c src/gc_scan.c src/gc_cli.c

OBJS := $(patsubst src/%.c,$(BUILD)/%.o,$(SRCS))
RES  := $(BUILD)/groundclean_res.o

.PHONY: all debug clean install

all: CFLAGS += -O2 -DNDEBUG
all: $(TARGET)

debug: CFLAGS += -O0 -g -DDEBUG
debug: $(TARGET)

$(BUILD):
	@mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(RES): res/groundclean.rc res/groundclean.manifest res/version.h | $(BUILD)
	$(WINDRES) -Iinclude -Ires $(if $(arch),$(if $(filter 64,$(arch)),-F pe-x86-64,-F pe-i386),) $< -O coff -o $@

$(TARGET): $(OBJS) $(RES)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

install: $(TARGET)
	install -m 0755 $(TARGET) /usr/local/bin/$(BIN)

clean:
	rm -rf $(BUILD)