REGISTRY := docker.tridentsystems.co.nz
DOCKERS := \
	ubuntu/texlive \
	ubuntu/texlive-r \
	ubuntu/gorbachev-base \
	ubuntu/trophia-tools \
	ubuntu/kahawai-build \
	ubuntu/layers-build \
	ubuntu/ems-build

BASEIMAGES := \
	ubuntu 

DOCKER_TARGETS := $(addsuffix /.docker,$(DOCKERS))
REGISTRY_DOCKERS := $(addprefix $(REGISTRY)/,$(DOCKERS))
BASEIMAGE_TARGETS := $(addsuffix /.official,$(BASEIMAGES))

.PHONY: all
all: $(DOCKER_TARGETS)

.PHONY: fetch
fetch:
	$(MAKE) -B $(BASEIMAGE_TARGETS)

.PHONY: push
push: $(REGISTRY_DOCKERS)

.PHONY: deploy
deploy: fetch all push


ubuntu/nz/.docker: ubuntu/.official
ubuntu/texlive/.docker: ubuntu/nz/.docker
ubuntu/texlive-r/.docker: ubuntu/texlive/.docker
ubuntu/gorbachev-base/.docker: ubuntu/texlive-r/.docker
ubuntu/trophia-tools/.docker: ubuntu/gorbachev-base/.docker

ubuntu/kahawai-build/.docker: ubuntu/nz/.docker
ubuntu/ems-build/.docker: ubuntu/nz/.docker
ubuntu/layers-build/.docker: ubuntu/kahawai-build/.docker

fetchofficial = @$(if $(filter-out $(shell cat $@ 2>/dev/null), $(shell docker inspect --format='{{.Id}}' $(1))), docker inspect --format='{{.Id}}' $(1)  > $(2))


.PHONY: clean
clean:
	for d in `find . -name .docker | xargs cat`; do docker rmi -f $d; done
	find . -name .docker -delete

ubuntu/.official:
	docker pull ubuntu:16.04
	$(call fetchofficial,ubuntu:16.04,$@)

%/.docker: %/Dockerfile %/*
	docker build -t $(REGISTRY)/$* $*
	@$(shell docker inspect --format='{{.Id}}' $(REGISTRY)/$*  > $@)

%/Dockerfile: %/Dockerfile.tmpl includes/df-user.inc includes/nz-locale.inc
	@cp $< $@
	@sed -i -e "/__INCLUDE_DF_USER__/r includes/df-user.inc" -e "//d" $@
	@sed -i -e "/__INCLUDE_NZ_LOCALE__/r includes/nz-locale.inc" -e "//d" $@

$(REGISTRY)/%: %/.docker
	docker push $(REGISTRY)/$*
