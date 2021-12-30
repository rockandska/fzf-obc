.ONESHELL:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c $(if $(V),-x)
_SPACE = $(eval) $(eval)
_COMMA := ,

#####
# vars
#####

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(realpath $(dir $(MKFILE_PATH)))
TARGET_EXTRA_ARGS ?=

# Softwares
SHELL_CHECK_VERSION := v0.7.0
BATS_VERSION := v1.5.0
FZF_VERSIONS := 0.18.0

# test
TEST_DIR := test
TEST_TARGETS_PREFIX := test
TEST_TARGETS = $(GITHUB_WORKFLOWS_TARGETS) $(TEST_SHELLCHECK_TARGETS) $(TEST_BATS_TARGETS) $(TEST_TMUX_TARGETS)
CLEAN := $(CLEAN) $(TEST_DIR)/tmp

# .github/workflows
GITHUB_WORKFLOWS_DIR := .github/workflows
GITHUB_WORKFLOWS_TARGETS_PREFIX := github-workflows
GITHUB_WORKFLOWS_TARGETS := $(wildcard $(GITHUB_WORKFLOWS_DIR)/*.yml)

# test/bats
TEST_BATS_DIR := test/bats
TEST_BATS_TARGETS_PREFIX := test-bats
TEST_BATS_TARGETS = $(addprefix $(TEST_BATS_TARGETS_PREFIX)-,$(TEST_BATS_DOCKER_IMAGES_LIST))
CLEAN := $(CLEAN) $(TEST_BATS_DIR)/tmp

# test/tmux
TEST_TMUX_DIR := test/tmux
TEST_TMUX_TARGETS_PREFIX := test-tmux
TEST_TMUX_TARGETS = $(addprefix $(TEST_TMUX_TARGETS_PREFIX)-,$(TEST_TMUX_DOCKER_IMAGES_LIST))
TEST_TMUX_FZF_VERSION := $(firstword $(FZF_VERSIONS))
TEST_TMUX_RUBY_VERSION := $(shell cat $(TEST_TMUX_DIR)/.ruby-version)
CLEAN := $(CLEAN) $(TEST_TMUX_DIR)/tmp

# test/bats/docker
TEST_BATS_DOCKER_DIR := test/bats/docker
TEST_BATS_DOCKER_GNU_LIST := true false
TEST_BATS_DOCKER_IMAGE_NAME := fzf-obc-test
TEST_BATS_DOCKER_DOCKERFILES_LIST = $(notdir $(basename $(wildcard $(TEST_BATS_DOCKER_DIR)/*.dockerfile)))
TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX := test-bats-docker-build
TEST_BATS_DOCKER_IMAGES_LIST = $(foreach gnu,$(TEST_BATS_DOCKER_GNU_LIST),$(addsuffix -gnu-$(gnu),$(TEST_BATS_DOCKER_DOCKERFILES_LIST)))
TEST_BATS_DOCKER_IMAGES_TARGETS = $(addprefix $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)-,$(TEST_BATS_DOCKER_IMAGES_LIST))

# test/tmux/docker
TEST_TMUX_DOCKER_DIR := test/tmux/docker
TEST_TMUX_DOCKER_IMAGE_NAME := fzf-obc-test
TEST_TMUX_DOCKER_DOCKERFILES_LIST = $(notdir $(basename $(wildcard $(TEST_TMUX_DOCKER_DIR)/*.dockerfile)))
TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX := test-tmux-docker-build
TEST_TMUX_DOCKER_IMAGES_LIST = $(foreach fzf,$(FZF_VERSIONS),$(addsuffix -fzf-$(fzf),$(TEST_TMUX_DOCKER_DOCKERFILES_LIST)))
TEST_TMUX_DOCKER_IMAGES_TARGETS = $(addprefix $(TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX)-,$(TEST_TMUX_DOCKER_IMAGES_LIST))

# test/shellcheck
TEST_SHELLCHECK_DIR := test/shellcheck
TEST_SHELLCHECK_TARGETS_PREFIX := test-shellcheck
TEST_SHELLCHECK_TARGETS := test-shellcheck
CLEAN := $(CLEAN) $(TEST_SHELLCHECK_DIR)/tmp

# PATH
export PATH := $(TEST_DIR)/tmp/bin:$(PATH)
export PATH := $(TEST_BATS_DIR)/tmp/bin:$(PATH)
export PATH := $(TEST_TMUX_DIR)/tmp/bin:$(PATH)
export PATH := $(TEST_SHELLCHECK_DIR)/tmp/bin:$(PATH)

#####
# Test targets
#""""
$(if $(strip $(TEST_TARGETS)),,$(error TEST_TARGETS empty))
$(if $(strip $(GITHUB_WORKFLOWS_TARGETS)),,$(error GITHUB_WORKFLOWS_TARGETS empty))
$(if $(strip $(TEST_BATS_TARGETS)),,$(error TEST_BATS_TARGETS empty))
$(if $(strip $(TEST_TMUX_TARGETS)),,$(error TEST_TMUX_TARGETS empty))
$(if $(strip $(TEST_SHELLCHECK_TARGETS)),,$(error TEST_SHELLCHECK_TARGETS empty))

#####
# Functions
#####

# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

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

#####
# Includes
#####

dir	:= .
include		$(dir)/Rules.mk

dir	:= test
include		$(dir)/Rules.mk

dir	:= .github/workflows
include		$(dir)/Rules.mk
