######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

######
# Include
######
dir	:= $(d)/tmux
include		$(dir)/Rules.mk

dir	:= $(d)/bats
include		$(dir)/Rules.mk
######
# Vars
######

#####
# Targets
#####

TEST_DOCKER_REGISTRY ?=
TEST_DOCKER_REGISTRY_USER ?= rockandska
TEST_DOCKER_REGISTRY_PASSWORD ?=
TEST_DOCKER_REGISTRY_NAMESPACE ?= rockandska/

.PHONY: test-docker-build-all
test-docker-build-all: $(TEST_DOCKER_TMUX_IMAGES_TARGETS)

.PHONY: test-docker-publish-all
test-docker-publish-all: $(TEST_DOCKER_TMUX_PUBLISH_TARGETS)

.PHONY: test-docker-login
.SECONDARY: test-docker-login
test-docker-login:
	$(info ##### Try to logging to docker registry $(TEST_DOCKER_REGISTRY) #####)
	docker login $(TEST_DOCKER_REGISTRY) < /dev/null 2> /dev/null || { \
		[[ $$'$(TEST_DOCKER_REGISTRY_PASSWORD)' == "" ]] \
		&& { 1>&2 echo "Error: TEST_DOCKER_REGISTRY_PASSWORD not set"; exit 1; } \
		|| docker login --username $(TEST_DOCKER_REGISTRY_USER) --password $$'$(TEST_DOCKER_REGISTRY_PASSWORD)' $(TEST_DOCKER_REGISTRY); \
	}

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
