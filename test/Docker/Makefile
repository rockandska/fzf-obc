SELF_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq ($(words $(subst :, ,$(SELF_DIR))), 1)
  $(error source directory cannot contain spaces or colons)
else ifneq ($(CURDIR),$(SELF_DIR))
  $(error Makefile need to be run from $(SELF_DIR))
endif

include $(SELF_DIR)/docker-images-list.mk

DOCKER_IMAGE_PREFIX := rockandska/fzf-obc-test
DOCKER_CONTAINER_PREFIX := fzf-obc-test

.PHONY: images
images: $(DOCKER_IMAGES_LIST)

.PHONY: image-%
image-%:
	$(info ###### Generating '$*' docker image #####)
	docker pull $(DOCKER_IMAGE_PREFIX):$* 2> /dev/null || true
	DOCKERFILE=$$(echo "$*" | cut -d "-" -f 1,2).dockerfile; \
		FZF_VERSION=$$(echo "$*" | cut -d "-" -f 4); \
		docker build -q -f $(SELF_DIR)/$${DOCKERFILE} --build-arg FZF_VERSION="$$FZF_VERSION" -t $(DOCKER_IMAGE_PREFIX):$* --cache-from $(DOCKER_IMAGE_PREFIX):$* $(SELF_DIR)

.PHONY: start-%
start-%: image-%
	docker rm -f $(DOCKER_CONTAINER_PREFIX)-$* 2> /dev/null || true
	docker create -ti --name $(DOCKER_CONTAINER_PREFIX)-$* $(DOCKER_IMAGE_PREFIX):$*
	docker start $(DOCKER_CONTAINER_PREFIX)-$*

.PHONY: stop-%
stop-%:
	docker stop $(DOCKER_CONTAINER_PREFIX)-$*
