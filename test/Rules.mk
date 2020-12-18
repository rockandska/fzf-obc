######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

######
# Include
######
dir	:= $(d)/Docker
include		$(dir)/Rules.mk

dir	:= $(d)/tmux
include		$(dir)/Rules.mk

#####
# Vars
#####
TEST_DIR := $(d)
TEST_ABS_DIR := $(MKFILE_DIR)$(d)

SHELL_CHECK_VERSION := v0.7.0
TEST_BASH_FILES := $(strip $(call rwildcard,.,*.sh *.bash))

CLEAN := $(CLEAN) $(TEST_DIR)/tmp

export PATH := $(TEST_ABS_DIR)/tmp/bin:$(PATH)

#####
# Targets
#####
.PHONY: test
test: test-shellcheck test-tmux

.PHONY: test-shellcheck
test-shellcheck: $(TEST_DIR)/tmp/bin/shellcheck
	$(info ##### Start tests with shellcheck #####)
	$(call check_cmd_path,shellcheck,$(TEST_ABS_DIR)/tmp/bin/shellcheck)
	shellcheck $(TEST_BASH_FILES)

#####################
# Test dependencies
#####################

.INTERMEDIATE: $(TEST_DIR)/tmp/bin/shellcheck
$(TEST_DIR)/tmp/bin/shellcheck: $(TEST_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TEST_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
$(TEST_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	$(call check_cmds,wget)
	mkdir -p $(@D)
	wget -qO- "https://github.com/koalaman/shellcheck/releases/download/$(SHELL_CHECK_VERSION)/shellcheck-$(SHELL_CHECK_VERSION).linux.x86_64.tar.xz" | tar -xJ -C $(TEST_DIR)/tmp/opt

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
