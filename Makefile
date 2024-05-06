.POSIX:

# Compiler settings
CC = emcc
CPPFLAGS = -MMD -MP -DSYNTH_LIB_ALONE
CFLAGS = -Wall -Wextra -pedantic -O3
LDFLAGS = -lm
LDLIBS = 

# Color codes for echo statements
GREEN = \033[1;92m
RESET = \033[0m

# Directory definitions
LIB_DIR := lib
BUILD_DIR := build
SRC_DIR := resynthesizer
EXAMPLE_DIR := examples

# File collection
SRCS := $(shell find $(SRC_DIR) -name '*.c')
OBJS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

# Include directories
INC_DIRS := $(shell find $(SRC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# Library output
STATIC_LIB := $(LIB_DIR)/libresynthesizer.a

# Examples
EXAMPLES := $(EXAMPLE_DIR)/painter_wasm

# Default target
all: $(STATIC_LIB) $(EXAMPLES)
	@echo "$(GREEN)Done!$(RESET)"

# Static library creation with emar
$(STATIC_LIB): $(OBJS)
	@echo "$(GREEN)Building $@$(RESET)"
	mkdir -p $(dir $@)
	emar rvs $@ $^

# Object file generation with emcc
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC_FLAGS) -c $< -o $@

# Example build rules with emcc
$(EXAMPLE_DIR)/painter_wasm: $(EXAMPLE_DIR)/painter_wasm.c $(STATIC_LIB)
	@echo "$(GREEN)Building $@$(RESET)"
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -o $@ -o index.html $< $(INC_FLAGS) $(STATIC_LIB) -s USE_SDL=2 -s USE_SDL=2 -s MODULARIZE=1 -s EXPORT_ES6=1

# Clean-up command
clean:
	$(RM) -r $(BUILD_DIR) $(LIB_DIR) $(EXAMPLES)

# Dependency inclusion
-include $(DEPS)
