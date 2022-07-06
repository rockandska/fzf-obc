######
# Include header
######
sp := $(sp).x
dirstack_$(sp) := $(d)
d := $(dir)

######
# targets
######

.PHONY: $(GITHUB_WORKFLOWS_TARGETS_PREFIX)
$(GITHUB_WORKFLOWS_TARGETS_PREFIX): $(GITHUB_WORKFLOWS_TARGETS)


$(GITHUB_WORKFLOWS_TARGETS): .FORCE
	printf '%s\n' '### Updating GHA $@ workflow ###'
	case "$(notdir $@)" in
		pull_request.yml)
			docker run --rm -v "$(MKFILE_DIR):$(MKFILE_DIR)" mikefarah/yq:4.9.6 -i eval '.jobs.Tests.strategy.matrix.target = [ "$(subst $(_SPACE),"$(_SPACE)$(_COMMA)$(_SPACE)",$(strip $(TEST_TARGETS)))" ]' $(MKFILE_DIR)/$@
			;;
		*)
			printf '%s\n' "Error: no update method found for $@"
			exit 1
	esac

#####
# Include footer
#####
d	:= $(dirstack_$(sp))
sp := $(basename $(sp))
