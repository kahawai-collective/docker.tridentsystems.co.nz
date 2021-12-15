DATE ?= $(shell date +%Y-%m-%d)
REGISTRY := docker.kahawai.net.nz
DOCKERS := \
	ubuntu/stan_2.26 


BASEIMAGES := \
	ubuntu \
	python

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
ubuntu/texlive/.docker: ubuntu/pisces/.docker
ubuntu/r/.docker: ubuntu/pisces/.docker
ubuntu/r-bleedingedge/.docker: ubuntu/pisces/.docker
ubuntu/texlive-r/.docker: ubuntu/r/.docker
ubuntu/texlive-r-bleedingedge/.docker: ubuntu/r-bleedingedge/.docker
ubuntu/gorbachev-base/.docker: ubuntu/texlive-r/.docker
ubuntu/gorbachev-base-bleedingedge/.docker: ubuntu/texlive-r-bleedingedge/.docker
ubuntu/jags-stan/.docker: ubuntu/gorbachev-base/.docker
ubuntu/stan_2.26/.docker: ubuntu/gorbachev-base-bleedingedge/.docker
ubuntu/trophia-tools/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fonz/.docker: ubuntu/r/.docker
ubuntu/inla/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fsl/.docker: ubuntu/gorbachev-base/.docker
ubuntu/nz-focal/.docker: ubuntu/.official
ubuntu/pisces-focal/.docker: ubuntu/nz-focal/.docker
ubuntu/ffmpeg/.docker: ubuntu/pisces-focal/.docker

ubuntu/kahawai-build/.docker: ubuntu/pisces/.docker
ubuntu/ems-build/.docker: ubuntu/gorbachev-base/.docker
ubuntu/ems2-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/layers-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/packhorse-build/.docker: ubuntu/kahawai-build/.docker

python/nz/.docker: python/.official
python/scikit/.docker: python/nz/.docker
python/pytorch/.docker: python/nz/.docker

fetchofficial = @$(if $(filter-out $(shell cat $@ 2>/dev/null), $(shell docker inspect --format='{{.Id}}' $(1))), docker inspect --format='{{.Id}}' $(1)  > $(2))


.PHONY: clean
clean:
	for d in `find . -name .docker | xargs cat`; do docker rmi -f $d; done
	find . -name .docker -delete

ubuntu/.official:
	docker pull ubuntu:18.04
	$(call fetchofficial,ubuntu:18.04,$@)

python/.official:
	docker pull python:3.10
	$(call fetchofficial,python:3.10,$@)

%/.docker: %/Dockerfile %/*
	docker build --iidfile $@ -t $(REGISTRY)/$* $*
	docker tag $(REGISTRY)/$* $(REGISTRY)/$*:$(DATE)

%/Dockerfile: %/Dockerfile.tmpl includes/df-user.inc includes/nz-locale.inc
	@cp $< $@
	@sed -i -e "/__INCLUDE_DF_USER__/r includes/df-user.inc" -e "//d" $@
	@sed -i -e "/__INCLUDE_NZ_LOCALE__/r includes/nz-locale.inc" -e "//d" $@

$(REGISTRY)/%: %/.docker
	docker push $(REGISTRY)/$*
	docker push $(REGISTRY)/$*:$(DATE)
