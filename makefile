# Define directories
CORE_DIR = ./core
DRIVERS_DIR = ./drivers
LIB_DIR = ./lib
BUILD_DIR = ./build

# Define target location
TARGET = $(BUILD_DIR)/test

# Define the linker script location
LD_SCRIPT = $(shell find $(CORE_DIR) -name *.ld)

# Define the startup file location
STARTUP = $(shell find $(CORE_DIR) -name *.s)

# Define the chip architecture
MCU_SPEC = cortex-m4
FPU_SPEC = fpv4-sp-d16

# Add the 'core' directory to the directories where to search for the include directories 
ifneq (,$(wildcard $(CORE_DIR)))
	DIRS += $(CORE_DIR)
endif

# If there is a 'drivers' directory, add it to the directories to search for the include directories
ifneq (,$(wildcard $(DRIVERS_DIR)))
    DIRS += $(DRIVERS_DIR)
endif

# If there is a 'lib' directory, add it to the directories to search for the include directories
ifneq (,$(wildcard $(LIB_DIR)))
    DIRS += $(LIB_DIR)
endif

# Define include directories (directories containing .h and .hpp files)
INC_DIRS = $(shell find $(DIRS) -type d -exec sh -c 'ls -1 "{}"/*.h > /dev/null 2>&1' \; -print)
INC_DIRS += $(shell find $(DIRS) -type d -exec sh -c 'ls -1 "{}"/*.hpp > /dev/null 2>&1' \; -print)

# Define include flags
INC_DIRS_FLAG = $(addprefix -I, $(INC_DIRS))

# Define source files location
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
CPPFLAGS += $(INC_DIRS_FLAG)

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
#LFLAGS += -nostdlib # Uncomment in order NOT to include the standard library
LFLAGS += -Wl,-Map=$(TARGET).map
LFLAGS += -lgcc
LFLAGS += -Wl,--gc-sections
LFLAGS += -Wl,--print-memory-usage
LFLAGS += -Wl,-L./ld
LFLAGS += -lc
LFLAGS += -nostartfiles
LFLAGS += -T$(LSCRIPT)

# If there is at least one startup file, define the correponding object(s) location
ifneq ($(STARTUP),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(STARTUP:.s=.o))
endif

# If there is at least one C file, define the correponding object(s) location
ifneq ($(C_SRCS),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(C_SRCS:.c=.o))
endif

# If there is at least one C++ file, define the correponding object(s) location
ifneq ($(CPP_SRCS),)
	OBJS += $(addprefix $(BUILD_DIR)/, $(CPP_SRCS:.cpp=.o))
endif

# Define the rm command according to the OS
ifeq ($(OS),Windows_NT)
  RM = cmd /C del /Q /F
else
  RM = rm -f
endif

# Entry point of the makefile
.PHONY: all
all: $(TARGET).bin 

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) -x assembler-with-cpp $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CPP) -c $(CPPFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CPP) -c $(CPPFLAGS) $< -o $@

$(TARGET).elf: $(OBJS)
	@mkdir -p $(dir $@)
	$(CPP) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	@mkdir -p $(dir $@)
	$(OC) -S -O binary $< $@

# Clean the project and rebuild it
.PHONY: fromscratch
fromscratch: clean $(TARGET).bin

# Clean the project
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

# Enter debug mode using gdb
.PHONY: debug
debug:
	st-util&
	arm-none-eabi-gdb -ex="target extended-remote : 4242" $(TARGET).elf
	pidof ../tools/st-util | xargs kill

# Flash the code into the board
.PHONY: flash
flash:
	st-flash --reset write $(TARGET).bin 0x08000000
