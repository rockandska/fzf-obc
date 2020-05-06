DOCKERFILES_LIST := debian-10
FZF_VERSIONS_LIST := 0.18.0

DOCKER_IMAGES_LIST :=$(foreach img,$(DOCKERFILES_LIST),$(foreach fzf,$(FZF_VERSIONS_LIST),$(shell echo "image-$(img)-fzf-$(fzf)")))
