REGISTRY := docker.kahawai.net.nz
DOCKERS := \
	ubuntu/kahawai-build \
	ubuntu/layers-build \
	ubuntu/ems-build \
	ubuntu/ems2-build \
	ubuntu/packhorse-build \
	ubuntu/r \
	ubuntu/fonz \
	ubuntu/texlive-r \
	ubuntu/gorbachev-base \
	ubuntu/jags-stan \
	ubuntu/stan_2.26 \
	ubuntu/trophia-tools \
	ubuntu/inla \
	ubuntu/fsl

ubuntu/r-bleedingedge \
ubuntu/texlive-r-bleedingedge \
ubuntu/gorbachev-base-bleedingedge \


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
ubuntu/pisces/.docker: ubuntu/nz/.docker
ubuntu/r/.docker: ubuntu/pisces/.docker
ubuntu/r-bleedingedge/.docker: ubuntu/pisces/.docker
ubuntu/texlive-r/.docker: ubuntu/r/.docker
ubuntu/texlive-r-bleedingedge/.docker: ubuntu/r-bleedingedge/.docker
ubuntu/gorbachev-base/.docker: ubuntu/texlive-r/.docker
ubuntu/gorbachev-base-bleedingedge/.docker: ubuntu/texlive-r-bleedingedge/.docker
ubuntu/jags-stan/.docker: ubuntu/gorbachev-base/.docker
ubuntu/stan_2.26/.docker: ubuntu/gorbachev-base/.docker
ubuntu/trophia-tools/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fonz/.docker: ubuntu/r/.docker
ubuntu/inla/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fsl/.docker: ubuntu/gorbachev-base/.docker


ubuntu/kahawai-build/.docker: ubuntu/pisces/.docker
ubuntu/ems-build/.docker: ubuntu/gorbachev-base/.docker
ubuntu/ems2-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/layers-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/packhorse-build/.docker: ubuntu/kahawai-build/.docker

fetchofficial = @$(if $(filter-out $(shell cat $@ 2>/dev/null), $(shell docker inspect --format='{{.Id}}' $(1))), docker inspect --format='{{.Id}}' $(1)  > $(2))


.PHONY: clean
clean:
	for d in `find . -name .docker | xargs cat`; do docker rmi -f $d; done
	find . -name .docker -delete

ubuntu/.official:
	docker pull ubuntu:18.04
	$(call fetchofficial,ubuntu:18.04,$@)

%/.docker: %/Dockerfile %/*
	docker build -t $(REGISTRY)/$* $*
	@$(shell docker inspect --format='{{.Id}}' $(REGISTRY)/$*  > $@)

%/Dockerfile: %/Dockerfile.tmpl includes/df-user.inc includes/nz-locale.inc
	@cp $< $@
	@sed -i -e "/__INCLUDE_DF_USER__/r includes/df-user.inc" -e "//d" $@
	@sed -i -e "/__INCLUDE_NZ_LOCALE__/r includes/nz-locale.inc" -e "//d" $@

$(REGISTRY)/%: %/.docker
	docker push $(REGISTRY)/$*
