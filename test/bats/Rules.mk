######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

#####
# Vars
#####
TEST_BATS_DIR := $(d)
TEST_BATS_ABS_DIR := $(MKFILE_DIR)/$(d)

TEST_BATS_TARGETS_PREFIX := test-bats-docker
TEST_BATS_TARGETS := $(addprefix $(TEST_BATS_TARGETS_PREFIX)-,$(TEST_DOCKER_BATS_IMAGES_LIST))

CLEAN := $(CLEAN) $(TEST_BATS_DIR)/tmp

export PATH := $(TEST_BATS_ABS_DIR)/tmp/bin:$(PATH)

#####
# Targets
#####

.PHONY: test-bats
test-bats: $(TEST_BATS_TARGETS_PREFIX)

.PHONY: $(TEST_BATS_TARGETS_PREFIX)
$(TEST_BATS_TARGETS_PREFIX): $(MKFILE_DIR)/.github/workflows/pull_request.yml $(TEST_BATS_TARGETS)

.PHONY: $(TEST_BATS_TARGETS)
$(TEST_BATS_TARGETS) : $(TEST_BATS_TARGETS_PREFIX)-% : $(TEST_DOCKER_BATS_IMAGES_TARGET_PREFIX)-% .github/workflows/pull_request.yml
	$(info ##### Start tests with bats on docker (image: $(addprefix $(TEST_DOCKER_BATS_IMAGE_NAME):,$*)) #####)
	docker run -i --rm -e BATS_PROJECT_DIR="$(MKFILE_DIR)" -v $(MKFILE_DIR):/${MKFILE_DIR}:ro $(addprefix $(TEST_DOCKER_TMUX_IMAGE_NAME):,$*) -r ${TEST_BATS_ABS_DIR}/spec/

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
