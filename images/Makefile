DATE ?= $(shell date +%Y-%m-%d)
HASH ?= $(shell git rev-parse HEAD | grep -o "^.\{8\}")
REGISTRY := docker.kahawai.net.nz
DOCKERS := \
	ubuntu/r-noble \
	ubuntu/texlive-r-noble \
	ubuntu/gorbachev-base-noble\

	#ubuntu/quarto 	

	#python/qc-reports	

	# ubuntu/r-jammy \
	# ubuntu/texlive-r-jammy \
	# ubuntu/gorbachev-base-jammy \
	# ubuntu/paua-jammy
	
	#ubuntu/r-noble \
	#ubuntu/texlive-r-noble \
	#ubuntu/gorbachev-base-noble

	#ubuntu/oceanum
	#python/pytorch

	#ubuntu/r-jammy \
	#ubuntu/texlive-r-jammy \
	#ubuntu/paua-jammy


    # ubuntu/r \
    # ubuntu/texlive \
    # ubuntu/texlive-r \
    # ubuntu/gorbachev-base-minimal

#    react-native-android/noto-stable
    # react-native-android/noto-dev

    # ubuntu/quarto \
	# ubuntu/kahawai-build \
    # ubuntu/fonz-focal \
    # ubuntu/kahawai-build \
    # ubuntu/r-jammy \
	# ubuntu/texlive-r-jammy \
	# ubuntu/gorbachev-base-jammy \
    # ubuntu/quarto \
	# ubuntu/r-bleedingedge \
	# ubuntu/texlive-r-bleedingedge \
 	# ubuntu/gorbachev-base-bleedingedge \
	# ubuntu/ems2-build \
    # ubuntu/r \
    # ubuntu/texlive \
    # ubuntu/texlive-r \
    # ubuntu/gorbachev-base \
	# ubuntu/trophia-tools \
	# ubuntu/texlive-r-focal \
	# ubuntu/gorbachev-base-focal \
	# ubuntu/bookdown \
	# ubuntu/stan_2.26 \
	# ubuntu/kahawai-build \
	# ubuntu/layers-build \
	# ubuntu/ems-build \
	# ubuntu/ems2-build \
	# ubuntu/packhorse-build \
	# ubuntu/fonz \
	# ubuntu/jags-stan \
	# ubuntu/stan_2.26 \
	# ubuntu/trophia-tools \
	# ubuntu/inla \
	# ubuntu/fsl \
	# python/scikit \
    # r-base/r-scraper \
    # ubuntu/ffmpeg \
	# ubuntu/r-focal \
	# python/pytorch \
	# python/flightdata	

BASEIMAGES := \
	ubuntu \
	python \
	r-base \
	react-native-android

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
ubuntu/r-focal/.docker: ubuntu/pisces-focal/.docker
ubuntu/r-jammy/.docker: ubuntu/pisces-jammy/.docker
ubuntu/r-noble/.docker: ubuntu/kahawai-noble/.docker
ubuntu/texlive-r/.docker: ubuntu/r/.docker
ubuntu/texlive-r-bleedingedge/.docker: ubuntu/r-bleedingedge/.docker
ubuntu/texlive-r-jammy/.docker: ubuntu/r-jammy/.docker
ubuntu/texlive-r-noble/.docker: ubuntu/r-noble/.docker
ubuntu/gorbachev-base/.docker: ubuntu/texlive-r/.docker
ubuntu/gorbachev-base-minimal/.docker: ubuntu/texlive-r/.docker
ubuntu/gorbachev-base-bleedingedge/.docker: ubuntu/texlive-r-bleedingedge/.docker
ubuntu/gorbachev-base-jammy/.docker: ubuntu/texlive-r-jammy/.docker
ubuntu/gorbachev-base-noble/.docker: ubuntu/texlive-r-noble/.docker
ubuntu/quarto/.docker: ubuntu/r-noble/.docker
ubuntu/jags-stan/.docker: ubuntu/gorbachev-base/.docker
#ubuntu/stan_2.26/.docker: ubuntu/gorbachev-base-bleedingedge/.docker
ubuntu/trophia-tools/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fonz/.docker: ubuntu/r/.docker
ubuntu/fonz-focal/.docker: ubuntu/r-focal/.docker
ubuntu/inla/.docker: ubuntu/gorbachev-base/.docker
ubuntu/fsl/.docker: ubuntu/gorbachev-base/.docker
ubuntu/nz-focal/.docker: ubuntu/.official
ubuntu/nz-jammy/.docker: ubuntu/.official
ubuntu/nz-noble/.docker: ubuntu/.noble
ubuntu/pisces-focal/.docker: ubuntu/nz-focal/.docker
ubuntu/pisces-jammy/.docker: ubuntu/nz-jammy/.docker
ubuntu/kahawai-noble/.docker: ubuntu/nz-noble/.docker
ubuntu/ffmpeg/.docker: ubuntu/pisces-focal/.docker
ubuntu/bookdown/.docker: ubuntu/pisces-focal/.docker
ubuntu/paua-jammy/.docker: ubuntu/gorbachev-base-jammy/.docker

ubuntu/kahawai-build/.docker: ubuntu/pisces/.docker
ubuntu/ems-build/.docker: ubuntu/gorbachev-base/.docker
ubuntu/ems2-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/layers-build/.docker: ubuntu/kahawai-build/.docker
ubuntu/packhorse-build/.docker: ubuntu/kahawai-build/.docker

python/nz/.docker: python/.official
python/scikit/.docker: python/nz/.docker
python/pytorch/.docker: python/nz/.docker
python/flightdata/.docker: python/nz/.docker
python/qc-reports/.docker: python/nz/.docker

r-base/nz/.docker: r-base/.official
r-base/r-scraper/.docker: r-base/nz/.docker

react-native-android/noto-dev/.docker: react-native-android/.official
react-native-android/noto-stable/.docker: react-native-android/.official

fetchofficial = @$(if $(filter-out $(shell cat $@ 2>/dev/null), $(shell docker inspect --format='{{.Id}}' $(1))), docker inspect --format='{{.Id}}' $(1)  > $(2))


.PHONY: clean
clean:
	for d in `find . -name .docker | xargs cat`; do docker rmi -f $d; done
	find . -name .docker -delete

ubuntu/.official:
	docker pull ubuntu:18.04
	$(call fetchofficial,ubuntu:18.04,$@)

ubuntu/.noble:
	docker pull ubuntu:24.04
	$(call fetchofficial,ubuntu:24.04,$@)

python/.official:
	docker pull python:3.13.2
	$(call fetchofficial,python:3.13.2,$@)

r-base/.official:
	docker pull r-base:4.1.2
	$(call fetchofficial,r-base:4.1.2,$@)

react-native-android/.official:
	docker pull reactnativecommunity/react-native-android:5.2
	$(call fetchofficial,reactnativecommunity/react-native-android:5.2,$@)

%/.docker: %/Dockerfile %/*
	docker build --iidfile $@ -t $(REGISTRY)/$* $*
	docker tag $(REGISTRY)/$* $(REGISTRY)/$*:$(DATE)
	docker tag $(REGISTRY)/$* $(REGISTRY)/$*:$(HASH)

%/Dockerfile: %/Dockerfile.tmpl includes/df-user.inc includes/nz-locale.inc
	@cp $< $@
	@sed -i -e "/__INCLUDE_DF_USER__/r includes/df-user.inc" -e "//d" $@
	@sed -i -e "/__INCLUDE_NZ_LOCALE__/r includes/nz-locale.inc" -e "//d" $@

$(REGISTRY)/%: %/.docker
	docker push $(REGISTRY)/$*
	docker push $(REGISTRY)/$*:$(DATE)
	docker push $(REGISTRY)/$*:$(HASH)	
