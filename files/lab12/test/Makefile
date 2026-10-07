# Lesson 12: run the cocotb tests with `make` inside this folder.
# Gate-level runs (GATES=yes) are handled by the Tiny Tapeout template's own Makefile.
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

VERILOG_SOURCES += $(SRC_DIR)/project.v $(PWD)/tb.v
COMPILE_ARGS    += -I$(SRC_DIR)

COCOTB_TOPLEVEL     = tb
COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim
