######
# Standard things
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

# Inlucdes

#dir	:= $(d)/docker
#include		$(dir)/Rules.mk

#####
# Targets
#####

.PHONY: $(TEST_BATS_TARGETS_PREFIX)
$(TEST_BATS_TARGETS_PREFIX): $(TEST_BATS_TARGETS)

.PHONY: $(TEST_BATS_TARGETS_PREFIX)-check-specs
.SECONDARY: $(TEST_BATS_TARGETS_PREFIX)-check-specs
$(TEST_BATS_TARGETS_PREFIX)-check-specs:
	$(info ##### Checking that all bash functions have their own bats spec)
	for file in $(SRC_FILES);do
		echo "$$file"
		case "$$file" in
			*/tmp/*|*/docs/*|*/test/*) continue ;;
			*/*.sh|*/*.bash) : ;;
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
			if [[ ! -f "${MKFILE_DIR}/test/bats/spec/$$f.bats" ]];then
				1>&2 echo "No bats spec found for function $$f found in $$file"
				exit 1
			fi
		done
	done

.PHONY: $(TEST_BATS_TARGETS)
$(TEST_BATS_TARGETS) : CURRENT_DIR := $(d)
$(TEST_BATS_TARGETS) : $(TEST_BATS_TARGETS_PREFIX)-% : $(TEST_BATS_TARGETS_PREFIX)-check-specs bin/fzf-obc $(GITHUB_WORKFLOWS_TARGETS) $(TEST_DOCKER_IMAGES_TARGET_PREFIX)-% $(PROGRAM)
	$(info ##### Start tests with bats on docker (image: $(addprefix $(TEST_DOCKER_IMAGE_NAME):,$*)) #####)
	mkdir -p $(TMP_DIR)
	docker run -ti --rm \
		-e BATS_PROJECT_DIR="$(MKFILE_DIR)" \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$$(id -u $$(whoami)):$$(id -g $$(whoami))" \
		-v $(MKFILE_DIR):$(MKFILE_DIR):ro \
		-v $(TMP_DIR):/tmp \
		$(addprefix $(TEST_DOCKER_IMAGE_NAME):,$*) \
		bats \
		--print-output-on-failure \
		-r $(MKFILE_DIR)/${TEST_BATS_DIR}/spec/ \
		$(TARGET_EXTRA_ARGS)

#####
# Standard things
#####
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))
