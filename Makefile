.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c $(if $(V),-x)
_SPACE = $(eval) $(eval)
_COMMA := ,

#####
# vars
#####

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(realpath $(dir $(MKFILE_PATH)))

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
# Includes
#####

dir	:= test
include		$(dir)/Rules.mk

#####
# Targets
#####

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: .FORCE
.FORCE:

.PHONY: all
all: test

.PHONY: test
test: $(MKFILE_DIR)/.github/workflows/pull_request.yml $(TEST_TARGETS)

.PHONY:		clean
clean:
	rm -rf $(CLEAN)

.SECONDARY:	$(CLEAN)

$(MKFILE_DIR)/.github/workflows/pull_request.yml: .FORCE
	printf '%s\n' '### Updating GHA pull_request workflow ###'
	docker run --rm -v "$(MKFILE_DIR):$(MKFILE_DIR)" mikefarah/yq:4.9.6 -i eval '.jobs.Tests.strategy.matrix.target = [ "$(subst $(_SPACE),"$(_SPACE)$(_COMMA)$(_SPACE)",$(strip $(TEST_TARGETS)))" ]' $@
