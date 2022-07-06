# Include header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

.PHONY: build
build: $(PROGRAM)

.PHONY: install
install: $(PROGRAM)
	install -d "$(PREFIX)/bin"
	install -t "$(PREFIX)/bin" bin/*

.PHONY:	clean
clean:
	rm -rf $(PROGRAM)

.PHONY:	dist-clean
dist-clean:
	rm -rf $(DIST_CLEAN)

.SECONDARY: $(PROGRAM)
$(PROGRAM): $(SRC_FILES)
	$(info ###### Building $@ #####)
	echo "#!/usr/bin/env bash" > $@
	grep -h -v '^#!' $^ >> $@

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: .FORCE
.FORCE:

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
