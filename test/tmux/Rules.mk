######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

# includes

#dir	:= $(d)/docker
#include		$(dir)/Rules.mk

# checks

ifndef TEST_TMUX_FZF_VERSION
  $(error TEST_TMUX_FZF_VERSION not set)
endif

#####
# Targets
#####

.PHONY: $(TEST_TMUX_TARGETS_PREFIX)
$(TEST_TMUX_TARGETS_PREFIX): $(TEST_TMUX_TARGETS)

.PHONY: $(TEST_TMUX_TARGETS)
$(TEST_TMUX_TARGETS): $(TEST_TMUX_TARGETS_PREFIX)-% : $(GITHUB_WORKFLOWS_TARGETS) $(PROGRAM) $(TEST_DOCKER_IMAGES_TARGET_PREFIX)-% python-env
	DOCKER_IMAGE=$(addprefix $(TEST_DOCKER_IMAGE_NAME):,$*)
	echo "##### Start tests with pytest and tmux on docker (image: $${DOCKER_IMAGE}) #####"
	DOCKER_IMAGE="$${DOCKER_IMAGE}" $(TMP_DIR)/bin/pytest $(if $(DEBUG), --tmux-debug) $(if $(V),-o log_cli=true -vv) $(TARGET_EXTRA_ARGS) $(TEST_TMUX_DIR)/tests


##############
# Python env #
##############
.PHONY: python-env
.SECONDARY: python-env
python-env: $(TMP_DIR)/bin/activate

.SECONDARY: $(TMP_DIR)/bin/activate
$(TMP_DIR)/bin/activate: $(TEST_TMUX_DIR)/requirements.txt $(TMP_DIR)/pyenv.done
	echo "##### Generating Python env #####"
	if ! cmdsexists 'virtualenv';then
		echo "##### Virtualenv not installed, try to install it..."
		pip3 install --quiet --quiet virtualenv
	fi
	if [ -n "${VIRTUAL_ENV:-}" ];then
		1>&2 echo "VIRTUAL_ENV '${VIRTUAL_ENV:-}' already set. Quit this VIRTUAL_ENV before running tests)"
		exit 1
	fi
	virtualenv --quiet -p python3 $(@D)/../
	VIRTUAL_ENV_DISABLE_PROMPT=true . $@ && pip install --quiet --quiet -Ur $<
	mkdir -p $(@D)
	touch $@

$(TMP_DIR)/pyenv.done: $(TEST_TMUX_DIR)/.python-version
	echo "##### Check presence of pyenv #####"
	if cmdsexists 'pyenv';then
		echo "##### Install python version(s) #####"
		eval "$$(pyenv init -)"
		pyenv install -s "$$(cat $(TEST_TMUX_DIR)/.python-version)"
		echo "##### Use version installed #####"
		export PYENV_VERSION="$$(cat $(TEST_TMUX_DIR)/.python-version)"
		python --version
		cmdsexists 'python' "$$(pyenv root)/shims"
		mkdir -p $(@D)
		touch $@
	fi

#####################
# Test dependencies
#####################

.INTERMEDIATE: $(TMP_DIR)/bin/fzf
$(TMP_DIR)/bin/fzf: $(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf
$(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf:
	$(info ##### Downloading fzf $(TEST_TMUX_FZF_VERSION))
	mkdir -p $(@D)
	wget -qO - "https://github.com/junegunn/fzf-bin/releases/download/$(TEST_TMUX_FZF_VERSION)/fzf-$(TEST_TMUX_FZF_VERSION)-linux_amd64.tgz" | tar -xz -C $(@D)

.INTERMEDIATE: $(TMP_DIR)/bin/fzf-tmux
$(TMP_DIR)/bin/fzf-tmux: $(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux
	mkdir -p $(@D)
	ln -r -f -s $< $@

.SECONDARY: $(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux
$(TMP_DIR)/opt/fzf-$(TEST_TMUX_FZF_VERSION)/fzf-tmux:
	$(info ##### Downloading fzf-tmux $(TEST_TMUX_FZF_VERSION))
	mkdir -p $(@D)
	wget -qO - "https://raw.githubusercontent.com/junegunn/fzf/$(TEST_TMUX_FZF_VERSION)/bin/fzf-tmux" > $@ && chmod +x $@

#####
# Include footer
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
