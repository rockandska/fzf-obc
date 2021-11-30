######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

# Inlucdes

dir	:= $(d)/docker
include		$(dir)/Rules.mk

#####
# Targets
#####

.PHONY: $(TEST_BATS_TARGETS_PREFIX)
$(TEST_BATS_TARGETS_PREFIX): $(GITHUB_WORKFLOWS_TARGETS) $(TEST_BATS_TARGETS)

.PHONY: $(TEST_BATS_TARGETS)
$(TEST_BATS_TARGETS) : $(TEST_BATS_TARGETS_PREFIX)-% : $(GITHUB_WORKFLOWS_TARGETS) $(TEST_BATS_DOCKER_IMAGES_TARGET_PREFIX)-%
	$(info ##### Start tests with bats on docker (image: $(addprefix $(TEST_BATS_DOCKER_IMAGE_NAME):,$*)) #####)
	docker run -i --rm -e BATS_PROJECT_DIR="$(MKFILE_DIR)" -v $(MKFILE_DIR):/${MKFILE_DIR}:ro $(addprefix $(TEST_TMUX_DOCKER_IMAGE_NAME):,$*) -r $(MKFILE_DIR)/${TEST_BATS_DIR}/spec/

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
