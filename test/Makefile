SELF_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq ($(words $(subst :, ,$(SELF_DIR))), 1)
  $(error source directory cannot contain spaces or colons)
else ifneq ($(CURDIR),$(SELF_DIR))
  $(error Makefile need to be run from $(SELF_DIR))
endif

include $(SELF_DIR)/Docker/docker-images-list.mk

export PATH := $(SELF_DIR)/bin:$(PATH)

BASH_FILES := $(shell find $(SELF_DIR)/../bin $(SELF_DIR)/../lib $(SELF_DIR)/../plugins \( -name '*.sh' -o -name '*.bash' \) )

SHELL_CHECK_VERSION := v0.7.0
RUBY_VERSION := $(shell cat $(SELF_DIR)/.ruby-version)
ifndef FZF_VERSIONS_LIST
	$(error FZF_VERSIONS_LIST not set)
endif
FZF_VERSION := $(firstword $(FZF_VERSIONS_LIST))
ifndef DOCKER_IMAGES_LIST
	$(error DOCKER_IMAGES_LIST not set)
endif

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

define check_cmds
  $(eval
  _EXECUTABLES = $(1)
  ifndef _EXECUTABLES
    $$(error Missing argument on 'check_cmds' call)
  endif
  $$(info Check required commands... ($$(_EXECUTABLES)))
  K := $$(foreach _exec,$$(_EXECUTABLES),\
    $$(if $$(shell PATH="$$(PATH)" which $$(_exec)),$$(info -- Ok -- Command '$$(_exec)' found in $$$$PATH),$$(eval _MISSING_EXEC ?= 1 )$$(info -- ERROR -- Missing '$$(_exec)' command)))
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
test-shellcheck: bin/shellcheck
	$(info ##### Start tests with shellcheck #####)
	$(call check_cmds,shellcheck)
	$(call check_cmd_path,shellcheck,$(SELF_DIR)/bin/shellcheck)
	shellcheck $(BASH_FILES)

.PHONY: test-tty
test-tty: test-tty-local test-tty-docker

.PHONY: test-tty-local
test-tty-local: vendor bin/fzf bin/fzf-tmux ruby-env python-env
	$(info ##### Start tests with minitest and tmux #####)
	$(call check_cmds,tmux python3 fzf fzf-tmux asciinema)
	$(call check_cmd_path,asciinema,$(SELF_DIR)/bin/asciinema)
	$(call check_cmd_path,fzf,$(SELF_DIR)/bin/fzf)
	$(call check_cmd_path,fzf-tmux,$(SELF_DIR)/bin/fzf-tmux)
	ruby --version
	BUNDLE_GEMFILE=Gemfile bundle exec ruby test-fzf-obc.rb

.PHONY: test-tty-docker
test-tty-docker: $(addprefix test-tty-docker-,$(DOCKER_IMAGES_LIST))

.PHONY: test-tty-docker-%
test-tty-docker-image-%: vendor ruby-env python-env
	$(shell echo "##### Start tests with minitest and tmux and docker (image: $*) #####")
	ruby --version
	$(MAKE) --no-print-directory -C $(SELF_DIR)/Docker image-$*
	DOCKER_IMAGE="$(DOCKER_IMAGE_PREFIX):$*" BUNDLE_GEMFILE=Gemfile bundle exec ruby test-fzf-obc.rb

############
# Ruby env
############

Gemfile.lock: Gemfile .ruby-version | ruby-env
	$(info ##### Updating Gemfile.lock #####)
	$(call check_cmds,bundle)
	-@rm Gemfile.lock
	BUNDLE_GEMFILE=Gemfile bundle lock

vendor: Gemfile.lock .ruby-version | ruby-env
	$(info ##### Downloading / Installing Ruby gems  #####)
	$(call check_cmds,bundle)
	BUNDLE_GEMFILE=Gemfile bundle install --path=vendor
	@touch $@

.PHONY: ruby-env
ruby-env: tmp/$(RB_TOOL).mk.env
	$(info ##### Loading Ruby ENV #####)
	$(eval include $<)

tmp/$(RB_TOOL).mk.env: .ruby-version
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

##############
# Python env #
##############

.PHONY: python-env
python-env: bin/activate

.PHONY: virtualenv
virtualenv:
ifeq (, $(shell command -v virtualenv 2> /dev/null))
	$(info Virtualenv not installed, try to install it...)
	pip3 install virtualenv
endif

bin/activate: requirements.txt | virtualenv
	$(info ##### Generating Python env #####)
	$(call check_cmds,python3 virtualenv)
ifdef VIRTUAL_ENV
	$(error VIRTUAL_ENV '$(VIRTUAL_ENV)' already set. Quit this VIRTUAL_ENV before running tests)
endif
	virtualenv -p $(shell which python3) $(SELF_DIR)
	. $@ && pip install -Ur requirements.txt

#####################
# Test dependencies
#####################

.PHONY: bin/shellcheck
bin/shellcheck: opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck
	@mkdir -p $(@D)
	@ln -f -s $(SELF_DIR)/$< $@

opt/shellcheck-$(SHELL_CHECK_VERSION)/shellcheck:
	$(info ##### Downloading Shellcheck $(SHELL_CHECK_VERSION))
	$(call check_cmds,wget)
	@mkdir -p $(@D)
	wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-"$(SHELL_CHECK_VERSION)".linux.x86_64.tar.xz" | tar -xJv -C opt

.PHONY: bin/fzf
bin/fzf: opt/fzf-$(FZF_VERSION)/fzf
	$(info ##### Linking opt/fzf-$(FZF_VERSION)/fzf -> bin/fzf #####)
	@mkdir -p $(@D)
	@ln -f -s $(SELF_DIR)/$< $@

opt/fzf-$(FZF_VERSION)/fzf:
	$(info ##### Downloading fzf $(FZF_VERSION))
	@mkdir -p $(@D)
	cd $(@D) ; wget -qO - "https://github.com/junegunn/fzf-bin/releases/download/$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tgz" | tar -xzf -

.PHONY: bin/fzf-tmux
bin/fzf-tmux: opt/fzf-$(FZF_VERSION)/fzf-tmux
	$(info ##### Linking opt/fzf-$(FZF_VERSION)/fzf-tmux -> bin/fzf-tmux #####)
	@mkdir -p $(@D)
	@ln -f -s $(SELF_DIR)/$< $@

opt/fzf-$(FZF_VERSION)/fzf-tmux:
	$(info ##### Downloading fzf-tmux $(FZF_VERSION))
	@mkdir -p $(@D)
	wget -qO - "https://raw.githubusercontent.com/junegunn/fzf/$(FZF_VERSION)/bin/fzf-tmux" > $@ && chmod +x $@

#########
# Clean
#########

.PHONY: clean
clean:
	rm -rf \
		.bundle/ \
		bin/ \
		lib/python*/ \
		opt/ \
		pyvenv.cfg \
		share/ \
		tmp/ \
		vendor/
