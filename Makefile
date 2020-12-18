SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

#####
# vars
#####

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

#####
# Functions
#####

# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

define check_cmd_path
  $(eval
  _EXECUTABLE = $(1)
  _EXPECTED_PATH = $(2)
  ifndef _EXECUTABLE
    $$(error Missing argument on 'check_cmd' call)
  endif
  _CMD_PATH = $$(shell PATH="$$(PATH)" which $$(_EXECUTABLE))
  ifdef _CMD_PATH
    ifdef _EXPECTED_PATH
      ifneq ($$(_CMD_PATH),$$(_EXPECTED_PATH))
        $$(error Expecting '$$(_EXECUTABLE)' to be in '$$(_EXPECTED_PATH)' but found in '$$(_CMD_PATH)')
      endif
    endif
  else
    $$(error '$$(_EXECUTABLE)' not found in $$$$PATH)
  endif
  )
endef

#####
# Targets
#####

.PHONY: all
all: test

.PHONY:		clean
clean:
	rm -rf $(CLEAN)

.SECONDARY:	$(CLEAN)

# invoking make V=1 will print everything
$(V).SILENT:

#####
# Includes
#####

dir	:= test
include		$(dir)/Rules.mk

