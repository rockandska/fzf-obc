SELF_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq ($(words $(subst :, ,$(SELF_DIR))), 1)
  $(error source directory cannot contain spaces or colons)
else ifneq ($(CURDIR),$(SELF_DIR))
  $(error Makefile need to be run from $(SELF_DIR))
endif

BASH_FILES := $(shell find $(SELF_DIR)/../bin $(SELF_DIR)/../lib $(SELF_DIR)/../plugins \( -name '*.sh' -o -name '*.bash' \) )

SHELL_CHECK_VERSION := v0.7.0
ASCIINEMA_VERSION := v2.0.2
RUBY_VERSION := $(shell cat $(SELF_DIR)/.ruby-version)

ifndef RUBY_VERSION
  $(error RUBY_VERSION is not set. Missing $(SELF_DIR)/.ruby-version file ?)
endif

ifneq (, $(shell command -v rvm 2> /dev/null))
  RB_TOOL = rvm
else ifneq (, $(shell command -v rbenv 2> /dev/null))
  RB_TOOL = rbenv
else
  RB_TOOL = unknown
endif

define check_cmds
  $(eval
  _EXECUTABLES = $(1)
  ifndef _EXECUTABLES
    $$(error Missing argument on 'check_cmds' call)
  endif
  $$(info Check required commands... ($$(_EXECUTABLES)))
  K := $$(foreach _exec,$$(_EXECUTABLES),\
    $$(if $$(shell which $$(_exec)),$$(info -- Ok -- Command '$$(_exec)' found in $$$$PATH),$$(eval _MISSING_EXEC ?= 1 )$$(info -- ERROR -- Missing '$$(_exec)' command)))
  ifdef _MISSING_EXEC
    $$(error Some required commands are not installed)
  endif
  )
endef

#######
# ALL #
#######

.PHONY: all
all: test-shellcheck test-tty

############
# tests
############

.PHONY: test-shellcheck
test-shellcheck: $(SELF_DIR)/bin/shellcheck
	$(info ##### Start tests with shellcheck #####)
	$(SELF_DIR)/bin/shellcheck $(BASH_FILES)

.PHONY: test-tty
test-tty: $(SELF_DIR)/vendor $(SELF_DIR)/bin/asciinema ruby-env
	$(info #### Start tests with minitest and tmux)
	$(call check_cmds,tmux python3)
	ruby --version
	BUNDLE_GEMFILE=$(SELF_DIR)/Gemfile bundle exec ruby $(SELF_DIR)/test-fzf-obc.rb

############
# Ruby env
############

$(SELF_DIR)/Gemfile.lock: $(SELF_DIR)/Gemfile $(SELF_DIR)/.ruby-version | ruby-env
	$(info ##### Updating Gemfile.lock #####)
	$(call check_cmds,bundle)
	@rm $(SELF_DIR)/Gemfile.lock
	BUNDLE_GEMFILE=$(SELF_DIR)/Gemfile bundle lock

$(SELF_DIR)/vendor: $(SELF_DIR)/Gemfile.lock $(SELF_DIR)/.ruby-version | ruby-env
	$(info ##### Downloading / Installing Ruby gems  #####)
	$(call check_cmds,bundle)
	BUNDLE_GEMFILE=$(SELF_DIR)/Gemfile bundle install --path=vendor
	@touch $@

.PHONY: ruby-env
ruby-env: $(SELF_DIR)/tmp/$(RB_TOOL).mk.env
	$(info ##### Loading Ruby ENV #####)
	$(eval include $<)

$(SELF_DIR)/tmp/$(RB_TOOL).mk.env: $(SELF_DIR)/.ruby-version
	$(info ##### Generating Ruby env file ##### )
	@mkdir -p $(@D)
ifeq (rvm,$(RB_TOOL))
	$(info -- OK -- rvm found in $$PATH)
	@rvm list | grep -E '\s+(ruby-)?$(RUBY_VERSION) ?' 1> /dev/null \
		&& echo "-- OK -- Ruby '$(RUBY_VERSION)' is installed" \
		|| { \
				echo "Ruby '$(RUBY_VERSION)' not installed" ; \
		    echo "Installing Ruby '$(RUBY_VERSION)' with rvm..." ; \
		    rvm install $(RUBY_VERSION); \
		  }
	@rvm $(RUBY_VERSION) do rvm env \
		| sed "s/\"//g;s/unset /undefine /;s/'//g;s/=/ := /;s/\$$PATH/\$${PATH}/" \
		> $@
else ifeq (rbenv,$(RB_TOOL))
	$(info -- OK -- rbenv found in $$PATH)
	@rbenv versions | grep -E '\s+$(RUBY_VERSION)( |$$)' 1> /dev/null \
		&& echo "-- OK -- Ruby '$(RUBY_VERSION)' is installed" \
		|| { \
				echo "Ruby '$(RUBY_VERSION)' not installed" ; \
				echo "Installing Ruby '$(RUBY_VERSION)' with rbenv..." ; \
				rbenv install $(RUBY_VERSION); \
			}
	@echo 'export PATH := $(shell rbenv root)/shims:$$(PATH)' > $@
	@echo 'export RBENV_VERSION = $(RUBY_VERSION)' >> $@
else
	$(error Neither 'rvm' or 'rbenv' was found in $$(PATH))
endif


#####################
# Test dependencies
#####################

$(SELF_DIR)/bin/shellcheck: $(SELF_DIR)/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	$(info ##### Installing Shellcheck $(SHELL_CHECK_VERSION))
	@mkdir -p $(@D)
	cp $< $@

$(SELF_DIR)/opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	$(call check_cmds,wget)
	@mkdir -p $(@D)
	wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-"$(SHELL_CHECK_VERSION)".linux.x86_64.tar.xz" | tar -xJv -C $(SELF_DIR)/opt

.PHONY: $(SELF_DIR)/bin/asciinema
$(SELF_DIR)/bin/asciinema: $(SELF_DIR)/opt/asciinema-$(ASCIINEMA_VERSION)
	$(info ##### Generating Asciinema $(SHELL_CHECK_VERSION) binary)
	$(call check_cmds,python3)
	@mkdir -p $(@D)
	@mkdir -p $${HOME}/.config/asciinema
	echo "#!/usr/bin/env bash\nPYTHONPATH='$(SELF_DIR)/opt/asciinema-$(ASCIINEMA_VERSION):$${PYTHONPATH}' python3 -m asciinema \"\$$@\"" > $@
	@chmod +x $@

$(SELF_DIR)/opt/asciinema-$(ASCIINEMA_VERSION):
	$(info ##### Downloading Asciinema $(SHELL_CHECK_VERSION))
	$(call check_cmds,git)
	git clone -b $(ASCIINEMA_VERSION) https://github.com/asciinema/asciinema.git $@

#########
# Clean
#########

.PHONY: clean
clean:
	rm -rf \
		$(SELF_DIR)/.bundle/ \
		$(SELF_DIR)/bin \
		$(SELF_DIR)/opt/ \
		$(SELF_DIR)/tmp/ \
		$(SELF_DIR)/vendor/
