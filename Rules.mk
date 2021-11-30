# Include header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: .FORCE
.FORCE:

.PHONY: all
all: $(TEST_TARGETS_PREFIX)

.PHONY:		clean
clean:
	rm -rf $(CLEAN)

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
