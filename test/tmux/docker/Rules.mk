# Inlucde header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

#####
# Targets
#####

# Build
.PHONY: $(TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX)
$(TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX): $(TEST_TMUX_DOCKER_IMAGES_TARGETS)

.PHONY: $(TEST_TMUX_DOCKER_IMAGES_TARGETS)
$(TEST_TMUX_DOCKER_IMAGES_TARGETS):
	DOCKERFILE="$(TEST_TMUX_DOCKER_DIR)/$(subst -fzf-,,$(strip $(foreach dockerfile,$(TEST_TMUX_DOCKER_DOCKERFILES_LIST),$(findstring $(dockerfile)-fzf-,$(@))))).dockerfile" 
	FZF_VERSION="$(subst -fzf-,,$(strip $(foreach fzf,$(FZF_VERSIONS),$(findstring -fzf-$(fzf),$@))))"
	$(info ##### Building '$(TEST_TMUX_DOCKER_IMAGE_NAME):$(subst $(TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX)-,,$@)' docker image #####)
	docker build \
		--quiet \
		-f $$DOCKERFILE \
		--build-arg FZF_VERSION="$$FZF_VERSION" \
		-t $(TEST_TMUX_DOCKER_IMAGE_NAME):$(subst $(TEST_TMUX_DOCKER_IMAGES_TARGET_PREFIX)-,,$@) \
		$(TEST_TMUX_DOCKER_DIR)

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
