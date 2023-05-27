CORE_DIR = ./core
DRIVERS_DIR = ./drivers
BUILD_DIR = ./build
STARLINK_DIR = ./startup
LIB_DIR = ./lib

TARGET = $(BUILD_DIR)/test

# Define the linker script location and chip architecture.
LD_SCRIPT = $(shell find $(CORE_DIR) -name *.ld)

STARTUP = $(shell find $(CORE_DIR) -name *.s)

MCU_SPEC = cortex-m4
FPU_SPEC = fpv4-sp-d16

C_INC = $(shell find $(CORE_DIR) $(DRIVERS_DIR) $(LIB_DIR) -type d -exec sh -c 'ls -1 "{}"/*.h > /dev/null 2>&1' \; -print)
CPP_INC = $(shell find $(CORE_DIR) $(DRIVERS_DIR) $(LIB_DIR) -type d -exec sh -c 'ls -1 "{}"/*.h > /dev/null 2>&1' \; -print)
CPP_INC += $(shell find $(CORE_DIR) $(DRIVERS_DIR) $(LIB_DIR) -type d -exec sh -c 'ls -1 "{}"/*.hpp > /dev/null 2>&1' \; -print)

C_INC_FLAG = $(addprefix -I, $(C_INC))
CPP_INC_FLAG = $(addprefix -I, $(CPP_INC))

C_SRCS = $(shell find $(CORE_DIR) $(DRIVERS_DIR) $(LIB_DIR) -name '*.c')
CPP_SRCS = $(shell find $(CORE_DIR) $(DRIVERS_DIR) $(LIB_DIR) -name '*.cpp')

# Toolchain definitions (ARM bare metal defaults)
TOOLCHAIN = /usr
CPP = $(TOOLCHAIN)/bin/arm-none-eabi-g++
AS  = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
LD  = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC  = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD  = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS  = $(TOOLCHAIN)/bin/arm-none-eabi-size

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -Og
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -Wall
ASFLAGS += -fmessage-length=0

# C and C++ compilation directives
CPPFLAGS += -mcpu=$(MCU_SPEC)
CPPFLAGS += -mthumb
CPPFLAGS += -march=armv7e-m
CPPFLAGS += -mfloat-abi=hard
CPPFLAGS += -mfpu=$(FPU_SPEC)
CPPFLAGS += -Wall
CPPFLAGS += -g3
CPPFLAGS += -Og
#CPPFLAGS += -fno-inline
CPPFLAGS += -fmessage-length=0 -fno-common
CPPFLAGS += -ffunction-sections -fdata-sections
CPPFLAGS += -fno-exceptions
CPPFLAGS += -fno-rtti
CPPFLAGS += -std=c++11

# Linker directives.
LSCRIPT = $(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -mfloat-abi=hard
LFLAGS += -mfpu=$(FPU_SPEC)
LFLAGS += -Wall
LFLAGS += -march=armv7e-m
LFLAGS += --static
LFLAGS += --specs=nosys.specs
#LFLAGS += -nostdlib
LFLAGS += -Wl,-Map=$(TARGET).map
LFLAGS += -lgcc
LFLAGS += -Wl,--gc-sections
LFLAGS += -Wl,--print-memory-usage
LFLAGS += -Wl,-L./ld
LFLAGS += -lc
LFLAGS += -nostartfiles
LFLAGS += -T$(LSCRIPT)

ifneq ($(STARTUP),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(STARTUP:.s=.o))
endif

ifneq ($(C_SRCS),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(C_SRCS:.c=.o))
endif

ifneq ($(CPP_SRCS),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(CPP_SRCS:.cpp=.o))
endif

ifeq ($(OS),Windows_NT)
  RM = cmd /C del /Q /F
else
  RM = rm -f
endif

.PHONY: all
all: $(TARGET).bin 

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) -x assembler-with-cpp $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CPP) -c $(CPPFLAGS) $(C_INC_FLAG) $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CPP) -c $(CPPFLAGS) $(CPP_INC_FLAG) $< -o $@

$(TARGET).elf: $(OBJS)
	@mkdir -p $(dir $@)
	$(CPP) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	@mkdir -p $(dir $@)
	$(OC) -S -O binary $< $@

.PHONY: fromscratch
fromscratch: clean $(TARGET).bin

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: debug
debug:
	st-util&
	arm-none-eabi-gdb -ex="target extended-remote : 4242" $(TARGET).elf
	pidof ../tools/st-util | xargs kill

.PHONY: flash
flash:
	st-flash --reset write $(TARGET).bin 0x08000000
