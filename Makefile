.DEFAULT_GOAL:=test

UNAME_S := $(shell uname -s)

SHELL_CHECK_VERSION := v0.6.0
ASCIINEMA_VERSION := v2.0.2

TEST_PATH := test
TEST_TMP_PATH := $(TEST_PATH)/tmp

TEST_CASTS_PATH := $(TEST_TMP_PATH)/casts
TEST_SPEC_PATH := $(TEST_PATH)/spec

DOC_PATH := docs
DOC_SRC_PATH := $(DOC_PATH)/src
IMG_PATH := $(DOC_PATH)/img
GIF_PATH := $(IMG_PATH)/tests

TEST_SPEC_FILES := $(wildcard $(TEST_SPEC_PATH)/*)
GIF_FILES := $(addprefix $(GIF_PATH)/,$(notdir $(TEST_SPEC_FILES:.rb=.gif)))

SPECS_CHANGED :=

ifeq ("$(UNAME_S)","Darwin")
  TEST_CMD := BUNDLE_GEMFILE=$(TEST_PATH)/Gemfile bundle exec ruby $(TEST_PATH)/test-fzf-obc.rb --exclude '/test_insmod(_home)?/'
else
  TEST_CMD := BUNDLE_GEMFILE=$(TEST_PATH)/Gemfile bundle exec ruby $(TEST_PATH)/test-fzf-obc.rb
endif

empty :=

space := $(empty) $(empty)

############
# Deps
############

.PHONY: deps
deps: $(TEST_PATH)/vendor $(TEST_PATH)/opt/shellcheck-$(SHELL_CHECK_VERSION) $(TEST_PATH)/opt/asciinema-$(ASCIINEMA_VERSION)

$(TEST_PATH)/vendor: $(TEST_PATH)/Gemfile.lock
	@bundle install --gemfile=$(TEST_PATH)/Gemfile --path=vendor
	@touch $@

$(TEST_PATH)/Gemfile.lock: $(TEST_PATH)/Gemfile
	@cd $(TEST_PATH) && bundle lock && cd -
	@touch $@

$(TEST_PATH)/opt:
	@test -d $@ || mkdir -p $@

$(TEST_PATH)/bin:
	@test -d $@ || mkdir -p $@

$(TEST_PATH)/opt/shellcheck-$(SHELL_CHECK_VERSION):
	@$(MAKE) --no-print-directory $(TEST_PATH)/opt
	@$(MAKE) --no-print-directory $(TEST_PATH)/bin
ifneq ("$(UNAME_S)","Darwin")
	@wget -q -O "$(TEST_PATH)/bin/shellcheck" "https://shellcheck.storage.googleapis.com/shellcheck-$(SHELL_CHECK_VERSION).linux-x86_64"
	@chmod +x $(TEST_PATH)/bin/shellcheck
endif
	touch $@

$(TEST_PATH)/opt/asciinema-$(ASCIINEMA_VERSION):
	@$(MAKE) --no-print-directory $(TEST_PATH)/opt
	@$(MAKE) --no-print-directory $(TEST_PATH)/bin
	@mkdir -p $${HOME}/.config/asciinema
	@git clone -b $(ASCIINEMA_VERSION) https://github.com/asciinema/asciinema.git $@
	@echo "#!/usr/bin/env bash\nPYTHONPATH='$(CURDIR)/test/opt/asciinema-$(ASCIINEMA_VERSION):$${PYTHONPATH}' python3 -m asciinema \"\$$@\"" > $(TEST_PATH)/bin/asciinema
	@chmod +x $(TEST_PATH)/bin/asciinema


############
# test
############

.PHONY: test
test: deps
ifneq ("$(UNAME_S)","Darwin")
		@printf "\n##### Start tests with shellcheck #####\n"
		@$(TEST_PATH)/bin/shellcheck fzf-obc.bash bash_completion.d/*
endif
	@printf "\n##### Start tests with minitest and tmux #####\n"
	@$(TEST_CMD)

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

# Generate demo gallery from functionnal tests
$(DOC_SRC_PATH)/tests_gallery.md: $(sort $(GIF_FILES))
	@printf "\n##### Generate demo gallery #####\n"
	@printf "# Demo Gallery\n**Those images are generated from the functional tests**\n" > $@
	@$(foreach ___img___, $+, printf "\n  - [$(notdir $(___img___:.gif=))](#$(notdir $(___img___:.gif=)))\n" >> $@;)
	@$(foreach ___img___, $+, printf "\n## $(notdir $(___img___:.gif=))\n![]($(subst $(DOC_PATH)/,../,$(___img___)))\n" >> $@;)

.PHONY: gifs
gifs: update_timestamp
	@$(MAKE) $(GIF_FILES)
	@$(if $(SPECS_CHANGED), \
		printf "\n##### Generation of casts files used to generate gifs #####\n"; \
		$(TEST_CMD) -n "/$(SPECS_CHANGED:|=)/"; \
		printf "\n##### Generation of gifs from casts files #####\n"; \
		$(foreach ___gif___, $(subst |,$(space),$(SPECS_CHANGED)), \
			docker run --rm --user $$(id -u) -v $(CURDIR)/$(TEST_CASTS_PATH):/data -v $(CURDIR)/$(GIF_PATH):/data/out asciinema/asciicast2gif -s 0.1 -w 80 -h 12 -S 1 "$(___gif___).cast" "out/$(___gif___).gif"; \
		) \
	)
	@$(MAKE) --no-print-directory $(IMG_PATH)/demo.gif
	@$(MAKE) --no-print-directory $(DOC_SRC_PATH)/tests_gallery.md

# Fix timestamp for *.gif and *.rb
# to avoid reconstruction when checkout
# or just touch a file
.PHONY: update_timestamp
update_timestamp: $(GIF_FILES)
	@for ___gif___ in $(GIF_FILES);do \
		if test -f $$___gif___; then \
			if git ls-files --full-name | grep "^$${___gif___}$$" 1> /dev/null; then \
				touch -m -t $$(git log -1 --format=%cd --date=format-local:%Y%m%d%H%M.%S -- $$___gif___) $$___gif___ ; \
			fi; \
		fi; \
	done;
	@for ___spec___ in $(TEST_SPEC_FILES);do \
		if test -f $$___spec___; then \
			if git ls-files --full-name | grep "^$${___spec___}$$" 1> /dev/null; then \
				if ! git diff --name-only HEAD | grep "^$${___spec___}$$" 1> /dev/null; then \
					touch -m -t $$(git log -1 --format=%cd --date=format-local:%Y%m%d%H%M.%S -- $${___spec___}) $${___spec___} ; \
				fi; \
			fi; \
		fi; \
	done;
