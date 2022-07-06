# Include header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

# Targets
.PHONY: $(TEST_SHELLCHECK_TARGETS)
$(TEST_SHELLCHECK_TARGETS): $(GITHUB_WORKFLOWS_TARGETS) $(TEST_SHELLCHECK_DIR)/tmp/bin/shellcheck bin/fzf-obc
	$(info ##### Start tests with shellcheck #####)
	$(call check_cmd_path,shellcheck,$(TEST_SHELLCHECK_DIR)/tmp/bin/shellcheck)
	shellcheck -s bash bin/fzf-obc

#####################
# Test dependencies
#####################

.INTERMEDIATE: $(TEST_SHELLCHECK_DIR)/tmp/bin/shellcheck
$(TEST_SHELLCHECK_DIR)/tmp/bin/shellcheck: $(TEST_SHELLCHECK_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TEST_SHELLCHECK_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
$(TEST_SHELLCHECK_DIR)/tmp/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	$(call check_cmds,wget)
	mkdir -p $(@D)
	wget -qO- "https://github.com/koalaman/shellcheck/releases/download/$(SHELL_CHECK_VERSION)/shellcheck-$(SHELL_CHECK_VERSION).linux.x86_64.tar.xz" | tar -xJ -C $(TEST_SHELLCHECK_DIR)/tmp/opt

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
