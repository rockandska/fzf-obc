# Include header
sp := $(sp).x
dirstack_$(sp) := $(d)
d	:= $(dir)

#####
# Targets
#####

# Build
.PHONY: $(TEST_DOCKER_IMAGES_TARGET_PREFIX)
$(TEST_DOCKER_IMAGES_TARGET_PREFIX): $(TEST_DOCKER_IMAGES_TARGETS)

.PHONY: $(TEST_DOCKER_IMAGES_TARGETS)
$(TEST_DOCKER_IMAGES_TARGETS):
	$(info ##### Building '$(TEST_DOCKER_IMAGE_NAME):$(subst $(TEST_DOCKER_IMAGES_TARGET_PREFIX)-,,$@)' docker image #####)
	DOCKERFILE="$(TEST_DOCKER_DIR)/$(subst -gnu-,,$(strip $(foreach dockerfile,$(TEST_DOCKER_DOCKERFILES_LIST),$(findstring $(dockerfile)-gnu-,$(@))))).dockerfile"
	GNU="$(subst -gnu-,,$(strip $(foreach gnu,$(TEST_DOCKER_GNU_LIST),$(findstring -gnu-$(gnu),$@))))"
	docker build \
		--quiet \
		-f "$$DOCKERFILE" \
		--build-arg GNU="$$GNU" \
		--build-arg BATS_VERSION="$(BATS_VERSION)" \
		-t $(TEST_DOCKER_IMAGE_NAME):$(subst $(TEST_DOCKER_IMAGES_TARGET_PREFIX)-,,$@) \
		$(TEST_DOCKER_DIR)

# Include footer
d := $(dirstack_$(sp))
sp := $(basename $(sp))
