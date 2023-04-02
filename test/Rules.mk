######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

######
# Include
######

dir	:= $(d)/docker
include		$(dir)/Rules.mk

dir	:= $(d)/tmux
include		$(dir)/Rules.mk

dir	:= $(d)/bats
include		$(dir)/Rules.mk

dir	:= $(d)/shellcheck
include		$(dir)/Rules.mk

#####
# Targets
#####

.PHONY: $(TEST_TARGETS_PREFIX)
$(TEST_TARGETS_PREFIX): $(GITHUB_WORKFLOWS_TARGETS) $(TEST_TARGETS)

#####
# Include footer
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
