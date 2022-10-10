# Include header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

$(PROGRAM): $(SRC_FILES) Makefile Rules.mk
	$(info ###### Building $@ #####)
	mkdir -p $(@D)
	echo "#!/usr/bin/env bash" > $@
	grep -h -v '^#!' $(SRC_FILES) >> $@

.PHONY: install
install: $(PROGRAM)
	install -d "$(PREFIX)/bin"
	install -t "$(PREFIX)/bin" $(PROGRAM)

.PHONY:	clean
clean: dist-clean
	rm -rf $(PROGRAM)
	rm -rf bin/

.PHONY:	dist-clean
dist-clean:
	rm -rf $(DIST_CLEAN)

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: .FORCE
.FORCE:

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
