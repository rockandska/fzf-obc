SELF_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq ($(words $(subst :, ,$(SELF_DIR))), 1)
  $(error source directory cannot contain spaces or colons)
else ifneq ($(CURDIR),$(SELF_DIR))
  $(error Makefile need to be run from $(SELF_DIR))
endif

TEST_PATH := test
TEST_TMP_PATH := $(TEST_PATH)/tmp/tty

TEST_CASTS_PATH := $(TEST_TMP_PATH)/casts
TEST_SPEC_PATH := $(TEST_PATH)/spec

DOC_PATH := docs
IMG_PATH := $(DOC_PATH)/img
GIF_PATH := $(IMG_PATH)/tests

TEST_SPEC_FILES := $(wildcard $(TEST_SPEC_PATH)/*)
GIF_FILES := $(addprefix $(GIF_PATH)/,$(notdir $(TEST_SPEC_FILES:.rb=.gif)))

SPECS_CHANGED :=

empty :=

space := $(empty) $(empty)

# Fix timestamp for *.gif and *.rb
# to avoid reconstruction when checkout
# or just touch a file
RESTORE_TIMESTAMP := @$(shell \
		for ___gif___ in $(GIF_FILES);do \
			if test -f $$___gif___; then \
				if git ls-files --full-name | grep "^$${___gif___}$$" 1> /dev/null; then \
					if ! git diff --name-only HEAD | grep "^$${___gif___}$$" 1> /dev/null; then \
						touch -d @$$(git log -1 --format="%at" -- $$___gif___) $$___gif___; \
					fi; \
				fi; \
			fi; \
		done; \
		for ___spec___ in $(TEST_SPEC_FILES);do \
			if test -f $$___spec___; then \
				if git ls-files --full-name | grep "^$${___spec___}$$" 1> /dev/null; then \
					if ! git diff --name-only HEAD | grep "^$${___spec___}$$" 1> /dev/null; then \
						touch -d @$$(git log -1 --format="%at" -- $${___spec___}) $${___spec___}; \
					fi; \
				fi; \
			fi; \
		done; \
	)

.PHONY: all
all: test

.PHONY: test
test:
	$(MAKE) --no-print-directory -C $(SELF_DIR)/test

clean:
	$(MAKE) -C $(SELF_DIR)/test clean


############
# docs
############

# When asking for docs/img/tests/*.gif
# Set SPECS_CHANGED with spec changed separated by |
$(GIF_PATH)/%.gif: $(TEST_SPEC_PATH)/%.rb
	$(eval SPECS_CHANGED := $(SPECS_CHANGED)$(notdir $(?:.rb=))|)

# Demo is based on specific tests
$(IMG_PATH)/demo.gif: $(GIF_PATH)/test_insmod.gif $(GIF_PATH)/test_docker.gif $(GIF_PATH)/test_git.gif
	@printf "\n##### Generating demo gif #####\n"
	@docker run --rm --user $$(id -u) -v "$(CURDIR)/$(GIF_PATH)":"$(CURDIR)/$(GIF_PATH)" -v "$(CURDIR)/$(IMG_PATH)":"$(CURDIR)/$(IMG_PATH)" starefossen/gifsicle -m $(addprefix $(CURDIR)/,$+) > $(CURDIR)/$(IMG_PATH)/demo.gif
	@echo OK

# Generate demo gallery from functionnal tests
$(DOC_PATH)/tests_gallery.md: $(sort $(GIF_FILES))
	@printf "\n##### Generate demo gallery #####\n"
	@printf "**Those images are generated from the functional tests**\n" > $@
	@$(foreach ___img___, $+, printf "\n## $(notdir $(___img___:.gif=))\n![]($(subst $(DOC_PATH)/,$(empty),$(___img___)))\n" >> $@;)
	@echo OK

.PHONY: gifs
gifs: $(GIF_FILES)
	@printf "\n##### Start demo gifs generations #####\n\n"
	@$(if $(SPECS_CHANGED), \
		printf "\n##### Generation of casts files used to generate gifs #####\n"; \
		BUNDLE_GEMFILE=test/Gemfile bundle exec ruby test/test-fzf-obc.rb -n "/^($(SPECS_CHANGED:|=))$$/"; \
	)
	@printf "\n##### Generation of gifs from casts files #####\n";
	@$(foreach ___gif___, $(subst |,$(space),$(SPECS_CHANGED)), \
		docker run --rm --user $$(id -u) -v $(CURDIR)/$(TEST_CASTS_PATH):/data -v $(CURDIR)/$(GIF_PATH):/data/out asciinema/asciicast2gif -s 0.1 -w 80 -h 12 -S 1 "$(___gif___).cast" "out/$(___gif___).gif"; \
	)
	@$(MAKE) --no-print-directory $(IMG_PATH)/demo.gif
	@$(MAKE) --no-print-directory $(DOC_PATH)/tests_gallery.md

.PHONY: docs
docs: gifs
