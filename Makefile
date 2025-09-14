# Test GNU MAKE
$(if $(strip $(MAKE_VERSION)),,$(error ** Error ** : GNU Make is required for this Makefile !))

# Softwares used for test
SHELLCHECK_VERSION := v0.7.0
BATS_VERSION := v1.5.0
FZF_VERSION := 0.18.0
BASH_VERSIONS = 3.2.57 4.1.17 4.3.48

.ONESHELL:
.DELETE_ON_ERROR:
SHELL := bash
.SHELLFLAGS := -Eeu -o pipefail $(if $(DEBUG),-x) -c
.DEFAULT_GOAL := $(PROGRAM)

_SPACE = $(eval) $(eval)
_COMMA := ,

PROGRAM := bin/fzf-obc
PROGRAM_NAME := fzf-obc
PREFIX ?= $(HOME)/.local
TMP_DIR = $(CURDIR)/test/tmp

# Used add args to commands
TARGET_EXTRA_ARGS ?=

# Src
SRC_FILES = src/*.sh src/fzf-obc

# GH Workflows
GH_SRC_FILES := .github/workflows/*.yml

DIST_CLEAN := $(PROGRAM)

# fzf-obc
$(PROGRAM): $(SRC_FILES)
	$(info *** Building $@ ***)
	mkdir -p $(@D)
	echo "#!/usr/bin/env bash" > $@
	grep -h -v '^#!' $(SRC_FILES) >> $@

.PHONY: install
install: $(PROGRAM)
	install -d "$(PREFIX)/bin"
	install -t "$(PREFIX)/bin" $(PROGRAM)

.PHONY:	clean
clean: dist-clean
	rm -rf $(TMP_DIR)

.PHONY:	dist-clean
dist-clean:
	rm -rf $(DIST_CLEAN)

.PHONY: shellcheck
shellcheck: gh-workflows $(PROGRAM)
	$(info *** Start tests with shellcheck ***)
	docker run --rm -it -v "$(CURDIR):/mnt:ro" koalaman/shellcheck:$(SHELLCHECK_VERSION) -s bash $(PROGRAM)

# Bats
TEST_BATS_PREFIX := test-bats
TEST_BATS_TARGETS := $(foreach bash,$(BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_BATS_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_BATS_PREFIX)))
TEST_BATS_IMAGE_NAME := fzf-obc-test
TEST_BATS_IMAGES_PREFIX := test-build-image

## bats test
.PHONY: $(TEST_BATS_PREFIX)
$(TEST_BATS_DOCKER): $(TEST_BATS_TARGETS)

.PHONY: $(TEST_BATS_PREFIX)-check-specs
.SECONDARY: $(TEST_BATS_PREFIX)-check-specs
$(TEST_BATS_PREFIX)-check-specs:
	$(info *** Checking that all bash functions have their own bats spec ***)
	for file in $(SRC_FILES);do
		echo "$(notdir $$file)"
		case "$(notdir $$file)" in
			*.sh|.bash) : ;;
			*)
				if [[ $$(file -b --mime-type "$$file") == text/x-shellscript ]];then
					:
				elif IFS= LC_ALL=C read -r shebang < "$$file" && [[ "$$shebang" =~ .*(/| )(bash|sh) ]];then
					:
				else
					continue
				fi
				;;
		esac
		functions=($$(grep -Pzo "(\n|^)\s*(function\s+)?(\w|:|-)+\s*\(\)\s*\n*\{" $$file | tr '\0' '\n' | sed -r 's/function //;/^\s*$$/d;/^\s*\{\s*$$/d;s/\(\)\s*(\{|$$)//' || true))
		for f in "$${functions[@]}";do
			echo "  Found -> $$f"
			if [[ ! -f "$(CURDIR)/test/bats/spec/$$f.bats" ]];then
				1>&2 echo "/!\ Error : No bats spec found for function $$f found in $$file"
				exit 1
			fi
		done
	done

.PHONY: $(TEST_BATS_TARGETS)
$(TEST_BATS_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_NAME)
$(TEST_BATS_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_BATS_TARGETS): BASH = $(filter $(BASH_VERSIONS),$(subst -, ,$@))
$(TEST_BATS_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_BATS_TARGETS) : $(TEST_BATS_PREFIX)-% : $(TEST_BATS_IMAGES_PREFIX)-% $(TEST_BATS_PREFIX)-check-specs $(PROGRAM) gh-workflows
	$(info *** Start tests with bats on docker (image: $(DOCKER_IMAGE):$(DOCKER_TAG) *** ))
	mkdir -p $(TMP_DIR)
	docker run -ti --rm \
		--init \
		-e BATS_PROJECT_DIR="$(CURDIR)" \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$$(id -u $$(whoami)):$$(id -g $$(whoami))" \
		-v $(CURDIR):$(CURDIR):ro \
		-v $(TMP_DIR):/tmp \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		bats \
		--print-output-on-failure \
		$(TARGET_EXTRA_ARGS) \
		-r \
		$(CURDIR)/test/bats/spec/

## Build bats image
TEST_BATS_IMAGES_TARGETS := $(foreach bash,$(BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_BATS_IMAGES_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_BATS_IMAGES_PREFIX)))

.PHONY: $(TEST_BATS_IMAGES_PREFIX)
$(TEST_BATS_IMAGES_PREFIX): $(TEST_BATS_IMAGES_TARGETS)

.PHONY: $(TEST_BATS_IMAGES_TARGETS)
$(TEST_BATS_IMAGES_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_NAME)
$(TEST_BATS_IMAGES_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_BATS_IMAGES_TARGETS): BASH = $(filter $(BASH_VERSIONS),$(subst -, ,$@))
$(TEST_BATS_IMAGES_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_BATS_IMAGES_TARGETS):
	$(info *** Building docker image $(DOCKER_IMAGE):$(DOCKER_TAG) ***)
	docker build \
		$(if $(DEBUG),,--quiet) \
		-f "$(CURDIR)/test/Dockerfile" \
		--build-arg GNU="$(GNU)" \
		--build-arg BASH_VER="$(BASH)" \
		--build-arg BATS_VERSION="$(BATS_VERSION)" \
		--build-arg FZF_VERSION="$(FZF_VERSION)" \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		test/

## Tmux
TEST_TMUX_PREFIX := test-tmux
TEST_TMUX_TARGETS := $(foreach bash,$(BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_TMUX_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_TMUX_PREFIX)))

.PHONY: $(TEST_TMUX_PREFIX)
$(TEST_TMUX_PREFIX): $(TEST_TMUX_TARGETS)

.PHONY: $(TEST_TMUX_TARGETS)
$(TEST_TMUX_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_NAME)
$(TEST_TMUX_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_TMUX_TARGETS): BASH = $(filter $(BASH_VERSIONS),$(subst -, ,$@))
$(TEST_TMUX_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_TMUX_TARGETS): $(TEST_TMUX_PREFIX)-% : $(TEST_BATS_IMAGES_PREFIX)-% gh-workflows $(PROGRAM) $(TMP_DIR)/bin/activate 
	$(info *** Start tests with tmux on docker (image: $(DOCKER_IMAGE):$(DOCKER_TAG) *** ))
	DOCKER_IMAGE="$(DOCKER_IMAGE):$(DOCKER_TAG)" $(TMP_DIR)/bin/pytest $(if $(DEBUG), --tmux-debug) $(if $(V),-o log_cli=true -vv) $(TARGET_EXTRA_ARGS) $(CURDIR)/test/tmux/tests


### python-env for tmux test
.SECONDARY: $(TMP_DIR)/bin/activate
$(TMP_DIR)/bin/activate: $(CURDIR)/test/tmux/requirements.txt $(TMP_DIR)/pyenv.done
	mkdir -p $(TMP_DIR)
	echo "*** Generating Python env ***"
	eval "$$(pyenv init -)"
	echo "*** Python version in use ***"
	python --version
	if [ -n "${VIRTUAL_ENV:-}" ];then
		1>&2 echo "VIRTUAL_ENV '${VIRTUAL_ENV:-}' already set. Quit this VIRTUAL_ENV before running tests)"
		exit 1
	fi
	pip install --quiet --quiet virtualenv
	virtualenv --quiet -p python3 $(TMP_DIR)
	VIRTUAL_ENV_DISABLE_PROMPT=true . $@ && pip install --quiet --quiet -Ur $<
	touch $@

$(TMP_DIR)/pyenv.done: $(CURDIR)/test/tmux/.python-version
	mkdir -p $(TMP_DIR)
	echo "*** Checking presence of pyenv ***"
	if command -v  "pyenv" &> /dev/null ;then
		echo "*** Installing python version(s) ***"
		eval "$$(pyenv init -)"
		pyenv install -s
		echo "*** Python version in use ***"
		python --version
		touch $@
	else
		1>&2 echo "Error: pyenv not installed !"
		exit 1
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

# Test

TEST_TARGETS = shellcheck $(TEST_BATS_TARGETS) $(TEST_TMUX_TARGETS)
.PHONY: test
test: $(TEST_TARGETS)

# github
.PHONY: gh-workflows
gh-workflows: $(GH_SRC_FILES)

$(GH_SRC_FILES): TMP_TARGETS = $(_SPACE)$(subst $(_SPACE),$(_SPACE)$(_COMMA)$(_SPACE),$(strip $(TEST_TARGETS) ))$(_SPACE)
$(GH_SRC_FILES): .FORCE
	printf '%s\n' '*** Updating GHA $@ workflow ***'
	case "$(notdir $@)" in
		pull_request.yml)
			docker run --rm -v "$(CURDIR):$(CURDIR)" mikefarah/yq:4.9.6 -i eval '.jobs.Tests.strategy.matrix.target = [ $(subst $(_SPACE),",$(TMP_TARGETS)) ]' $(CURDIR)/$@
			;;
		*)
			printf '%s\n' "Error: no update method found for $@"
			exit 1
	esac

# invoking make V=1 will print everything
$(V).SILENT:

.PHONY: .FORCE
.FORCE:
