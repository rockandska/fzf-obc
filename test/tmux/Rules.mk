######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

#####
# Vars
#####
TEST_TMUX_DIR := $(d)
TEST_TMUX_ABS_DIR := $(MKFILE_DIR)/$(d)

TEST_TMUX_FZF_VERSION := $(firstword $(TEST_DOCKER_TMUX_FZF_VERSIONS_LIST))

TEST_TMUX_TARGETS_PREFIX := test-tmux-docker
TEST_TMUX_TARGETS := $(addprefix $(TEST_TMUX_TARGETS_PREFIX)-,$(TEST_DOCKER_TMUX_IMAGES_LIST))
TEST_TMUX_RUBY_VERSION := $(shell cat $(TEST_TMUX_DIR)/.ruby-version)

CLEAN := $(CLEAN) $(TEST_TMUX_DIR)/tmp

export PATH := $(TEST_TMUX_ABS_DIR)/tmp/bin:$(PATH)

ifneq (, $(shell command -v rvm 2> /dev/null))
  TEST_TMUX_RB_TOOL = rvm
else ifneq (, $(shell command -v rbenv 2> /dev/null))
  TEST_TMUX_RB_TOOL = rbenv
else
  TEST_TMUX_RB_TOOL = unknown
endif

ifndef TEST_TMUX_RUBY_VERSION
  $(error TEST_TMUX_RUBY_VERSION is not set. Missing $(TEST_TMUX_DIR)/.ruby-version file ?)
endif

ifndef TEST_TMUX_FZF_VERSION
  $(error TEST_TMUX_FZF_VERSION not set)
endif

#####
# Targets
#####

.PHONY: test-tmux
test-tmux: $(TEST_TMUX_TARGETS_PREFIX)

.PHONY: $(TEST_TMUX_TARGETS_PREFIX)
$(TEST_TMUX_TARGETS_PREFIX): $(TEST_TMUX_TARGETS)

.PHONY: $(TEST_TMUX_TARGETS)
$(TEST_TMUX_TARGETS) : $(TEST_TMUX_TARGETS_PREFIX)-% : $(MKFILE_DIR)/.github/workflows/pull_request.yml $(TEST_DOCKER_TMUX_IMAGES_TARGET_PREFIX)-% ruby-env python-env
	$(info ##### Start tests with minitest and tmux on docker (image: $(addprefix $(TEST_DOCKER_TMUX_IMAGE_NAME):,$*)) #####)
	$(call check_cmd_path,asciinema,$(TEST_TMUX_ABS_DIR)/tmp/bin/asciinema)
	ruby --version
	DOCKER_IMAGE=$(addprefix $(TEST_DOCKER_TMUX_IMAGE_NAME):,$*) \
		BUNDLE_GEMFILE=$(TEST_TMUX_DIR)/Gemfile \
		BUNDLE_PATH=tmp/vendor \
		bundle exec ruby $(TEST_TMUX_DIR)/test-fzf-obc.rb

############
# Ruby env
############

.SECONDARY: $(TEST_TMUX_DIR)/Gemfile.lock
$(TEST_TMUX_DIR)/Gemfile.lock: $(TEST_TMUX_DIR)/Gemfile
	$(info ##### Updating Gemfile.lock #####)
	$(call check_cmds,bundle)
	ruby --version
	BUNDLE_GEMFILE=$(@D)/Gemfile bundle lock
	touch $@

.SECONDARY: $(TEST_TMUX_DIR)/tmp/vendor
$(TEST_TMUX_DIR)/tmp/vendor: $(TEST_TMUX_DIR)/Gemfile.lock
	$(info ##### Downloading / Installing Ruby gems #####)
	$(call check_cmds,bundle)
	ruby --version
	BUNDLE_GEMFILE=$(@D)/../Gemfile BUNDLE_PATH=tmp/vendor bundle install --quiet
	touch $@

.PHONY: ruby-env
.SECONDARY: ruby-env
ruby-env: $(TEST_TMUX_DIR)/tmp/$(TEST_TMUX_RB_TOOL).mk.env
	$(info ##### Loading Ruby $(TEST_TMUX_RB_TOOL) env file #####)
	$(eval include $<)
	$(MAKE) $(TEST_TMUX_DIR)/tmp/vendor -s --no-print-directory

.SECONDARY: $(TEST_TMUX_DIR)/tmp/rbenv.mk.env
$(TEST_TMUX_DIR)/tmp/rbenv.mk.env: $(TEST_TMUX_DIR)/.ruby-version
	$(info ##### Generating Ruby rbenv env file ##### )
	mkdir -p $(@D)
	rbenv versions | grep -E '\s+$(TEST_TMUX_RUBY_VERSION)( |$$)' 1> /dev/null \
		&& echo "-- OK -- Ruby '$(TEST_TMUX_RUBY_VERSION)' is installed" \
		|| { \
				echo "Ruby '$(TEST_TMUX_RUBY_VERSION)' not installed" ; \
				echo "Installing Ruby '$(TEST_TMUX_RUBY_VERSION)' with rbenv..." ; \
				rbenv install $(TEST_TMUX_RUBY_VERSION); \
			}
	echo 'export PATH := $(shell rbenv root)/shims:$$(PATH)' > $@
	echo 'export RBENV_VERSION = $(TEST_TMUX_RUBY_VERSION)' >> $@

.SECONDARY: $(TEST_TMUX_DIR)/tmp/rvm.mk.env
$(TEST_TMUX_DIR)/tmp/rvm.mk.env: $(TEST_TMUX_DIR)/.ruby-version
	$(info ##### Generating Ruby rvm env file ##### )
	mkdir -p $(@D)
	rvm list | grep -E '\s+(ruby-)?$(TEST_TMUX_RUBY_VERSION) ?' 1> /dev/null \
		&& echo "-- OK -- Ruby '$(TEST_TMUX_RUBY_VERSION)' is installed" \
		|| { \
				echo "Ruby '$(TEST_TMUX_RUBY_VERSION)' not installed" ; \
		    echo "Installing Ruby '$(TEST_TMUX_RUBY_VERSION)' with rvm..." ; \
		    rvm install $(TEST_TMUX_RUBY_VERSION); \
		  }
	rvm $(TEST_TMUX_RUBY_VERSION) do rvm env \
		| sed "s/\"//g;s/unset /undefine /;s/'//g;s/=/ := /;s/\$$PATH/\$${PATH}/" \
		> $@

.SECONDARY: $(TEST_TMUX_DIR)/tmp/unknown.mk.env
$(TEST_TMUX_DIR)/tmp/unknown.mk.env: $(TEST_TMUX_DIR)/.ruby-version
	$(info ##### Neither 'rvm' or 'rbenv' was found in $$(PATH) #####)
	$(info ##### /!\ Try with local ruby ##### )
	mkdir -p $(@D)
	touch $@

##############
# Python env #
##############
.PHONY: python-env
.SECONDARY: python-env
python-env: $(TEST_TMUX_DIR)/tmp/bin/activate

.SECONDARY: $(TEST_TMUX_DIR)/tmp/bin/activate
$(TEST_TMUX_DIR)/tmp/bin/activate: $(TEST_TMUX_DIR)/requirements.txt
	$(info ##### Generating Python env #####)
	$(call check_cmds,python3 pip3)
ifeq (, $(shell command -v virtualenv 2> /dev/null))
	$(info ##### Virtualenv not installed, try to install it...)
	pip3 install --quiet --quiet virtualenv
endif
ifdef VIRTUAL_ENV
	$(error VIRTUAL_ENV '$(VIRTUAL_ENV)' already set. Quit this VIRTUAL_ENV before running tests)
endif
	virtualenv --quiet -p $(shell command -v python3) $(@D)/../
	VIRTUAL_ENV_DISABLE_PROMPT=true . $@ && pip install --quiet --quiet -Ur $<
	touch $@

#####################
# Test dependencies
#####################

.INTERMEDIATE: $(TEST_TMUX_DIR)/tmp/bin/fzf
$(TEST_TMUX_DIR)/tmp/bin/fzf: $(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf
$(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf:
	$(info ##### Downloading fzf $(TEST_TMUX_FZF_VERSION))
	mkdir -p $(@D)
	wget -qO - "https://github.com/junegunn/fzf-bin/releases/download/$(TEST_TMUX_FZF_VERSION)/fzf-$(TEST_TMUX_FZF_VERSION)-linux_amd64.tgz" | tar -xz -C $(@D)

.INTERMEDIATE: $(TEST_TMUX_DIR)/tmp/bin/fzf-tmux
$(TEST_TMUX_DIR)/tmp/bin/fzf-tmux: $(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux
$(TEST_TMUX_DIR)/tmp/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux:
	$(info ##### Downloading fzf-tmux $(TEST_TMUX_FZF_VERSION))
	mkdir -p $(@D)
	wget -qO - "https://raw.githubusercontent.com/junegunn/fzf/$(TEST_TMUX_FZF_VERSION)/bin/fzf-tmux" > $@ && chmod +x $@

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
