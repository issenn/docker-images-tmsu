# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

NAME                       := TMSU
CC                         := gcc                            # compiler to use
DOCKER                     := $(shell docker --version)

# DOCKER_REGISTRY            ?= quay.io
IMAGE_NAME                 := tmsu
IMAGE_PREFIX               ?= issenn
IMAGE_TAG                  ?= latest

ifdef DOCKER_REGISTRY
    REPOSITORY             := $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)/$(IMAGE_NAME)
else
    REPOSITORY             := $(IMAGE_PREFIX)/$(IMAGE_NAME)
endif

TMSU_VERSION               ?= 0.7.5
# https://docs.brew.sh/Cask-Cookbook
# TMSU_VERSION_MAJOR         := $(shell echo $(TMSU_VERSION) | sed "s/^\([0-9]*\).*/\1/")
TMSU_VERSION_MAJOR         := $(shell echo $(TMSU_VERSION) | cut -f1 -d.)
# TMSU_VERSION_MINOR         := $(shell echo $(TMSU_VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
TMSU_VERSION_MINOR         := $(shell echo $(TMSU_VERSION) | cut -f2 -d.)
# TMSU_VERSION_PATCH         := $(shell echo $(TMSU_VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
TMSU_VERSION_PATCH         := $(shell echo $(TMSU_VERSION) | cut -f3 -d.)
TMSU_VERSION_MAJOR_MINOR   := $(TMSU_VERSION_MAJOR).$(TMSU_VERSION_MINOR)

# TMSU_BUILD                 := $(shell git log --oneline | wc -l | sed -e "s/[ \t]*//g")
COMMIT                     := $(shell git rev-parse HEAD)
# LAST_TAG_COMMIT            := $(shell git rev-list --tags --max-count=1)
# LAST_TAG                   := $(shell git describe --tags $(LAST_TAG_COMMIT) )
# REVISION                   := $(shell git rev-list $(LAST_TAG).. --count)
TAG_PREFIX                 := "v"

# HELM                       ?= helm
LABEL                      ?= "Maintainer=Issenn <issenn@issenn.ml>"
PUSH_IMAGE                 ?= false
LATEST                     := latest

PROXY                      ?= socks5://10.0.0.131:10808
NO_PROXY                   ?= localhost,127.0.0.1
USE_PROXY                  ?= true

OS                         ?= stretch
BASE_IMAGE                 ?= golang:1.15.15-$(OS)
ARCH                       ?= $(shell uname -m)

DOCKER_BUILDKIT            ?= false

IMAGE_DIR                  := $(TMSU_VERSION_MAJOR_MINOR)/$(OS)
DIST_FILE                  := tmsu-$(ARCH)-$(TMSU_VERSION)


default: all
	@echo 'Run `make options` for a list of all options'

options: help
	@echo
	@echo 'Options:'
	@echo 'DOCKER = $(DOCKER)'
	@echo 'DOCDIR = $(DOCDIR)'
	@echo 'DESTDIR = $(DESTDIR)'

help:
	@echo 'make:                 Test and compile tmsu.'
	@echo 'make images:          .'
	@echo 'make install:         Install $(NAME)'
	@echo 'make clean:           Remove the compiled files'
	@echo 'make doc:             Create the documentation'
	@echo 'make cleandoc:        Remove the documentation'
	@echo 'make man:             Compile the manpage with "pod2man"'
	@echo 'make manhtml:         Compile the html manpage with "pod2html"'
	@echo 'make snapshot:        Create a Tarball of the current git revision'
	@echo 'make test:            Test everything'
	@echo 'make test_other:      Verify the manpage is complete'
	@echo 'make test_shellcheck: Test using shellcheck'
	@echo 'make todo:            Look for TODO and XXX markers in the source code'

all: build

.PHONY: images
images: build-image

.PHONY: $(IMAGE_NAME)
$(IMAGE_NAME):
	@echo "  "
	@echo "===== Processing [$@] image ====="

.PHONY: build-image
build-image: $(IMAGE_NAME)
    ifeq ($(USE_PROXY), true)
	    env DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) \
	        docker build -t $(REPOSITORY):$(IMAGE_TAG) \
	            -f $(IMAGE_DIR)/Dockerfile \
	            --label $(LABEL) \
	            --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	            --build-arg VERSION=$(TMSU_VERSION) \
	            --build-arg HTTP_PROXY="$(PROXY)" \
	            --build-arg HTTPS_PROXY="$(PROXY)" \
	            --build-arg NO_PROXY="$(NO_PROXY)" .
    else
	    env DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) \
	        docker build -t $(REPOSITORY):$(IMAGE_TAG) \
	            -f $(IMAGE_DIR)/Dockerfile \
	            --label $(LABEL) \
	            --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	            --build-arg VERSION=$(TMSU_VERSION) .
    endif

    ifeq ($(PUSH_IMAGE), true)
	    docker push $(REPOSITORY):$(IMAGE_TAG)
	    docker tag $(REPOSITORY):$(IMAGE_TAG) $(REPOSITORY):$(COMMIT)
	    docker push $(REPOSITORY):$(COMMIT)
    endif

.PHONY: generate-for-docker
generate-for-docker:
	@echo "Creating Dockerfile..."
	@mkdir -p build/$(IMAGE_DIR); \
	cat $(IMAGE_DIR)/Dockerfile Dockerfile.export > build/$(IMAGE_DIR)/Dockerfile

.PHONY: build-in-docker
build-in-docker: generate-for-docker
    ifeq ($(USE_PROXY), true)
	    env DOCKER_BUILDKIT=true \
	        docker build \
	            --file build/$(IMAGE_DIR)/Dockerfile \
	            --target export-stage \
	            --output type=local,dest=out/$(IMAGE_DIR) \
	            --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	            --build-arg ARCH=$(ARCH) \
	            --build-arg VERSION=$(TMSU_VERSION) \
	            --build-arg HTTP_PROXY="$(PROXY)" \
	            --build-arg HTTPS_PROXY="$(PROXY)" \
	            --build-arg NO_PROXY="$(NO_PROXY)" .
    else
	    env DOCKER_BUILDKIT=true \
	        docker build \
	            --file build/$(IMAGE_DIR)/Dockerfile \
	            --target export-stage \
	            --output type=local,dest=out/$(IMAGE_DIR) \
	            --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	            --build-arg ARCH=$(ARCH) \
	            --build-arg VERSION=$(TMSU_VERSION) .
    endif

build : build-in-docker test compile
	@echo "Build TMSU v$(TMSU_VERSION)."

test :

compile :

clean :
	@echo "Cleaning up..."
	rm -rf build
	rm -rf out

.PHONY : clean-docker-cache
clean-docker-cache :
	docker builder prune

.PHONY : show-docker-system-df
show-docker-system-df:
	docker system df

.PHONY : default options help all build test compile clean
