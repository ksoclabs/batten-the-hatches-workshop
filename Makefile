SHELL := /usr/bin/env bash

IMAGENAME=k8sworkshop
IMAGEREPO=ksoclabs/$(IMAGENAME)
WORKDIR=/data
SERVEPORT=8080

DOCKER=docker build -t $(IMAGEREPO):latest .
COMMAND=docker run --user=`id -u`:`id -g` --rm -v `pwd`:$(WORKDIR)
BUILD=$(COMMAND) $(IMAGEREPO):latest build
SERVE=$(COMMAND) -p $(SERVEPORT):$(SERVEPORT) $(IMAGEREPO):latest serve
DEBUGSHELL=$(COMMAND) -v /etc/passwd:/etc/passwd:ro -v /home:/home:ro -it --entrypoint "sh" $(IMAGEREPO):latest

dockerbuild:
	@echo "Building $(IMAGEREPO):latest"
	@$(DOCKER)
dockerpush:
	@echo "Building $(IMAGEREPO):latest"
	@$(DOCKER)

build:
	@echo "Running site build in $(IMAGEREPO):latest"
	@$(BUILD)
serve:
	@echo "Starting $(IMAGEREPO):latest on port localhost:$(SERVEPORT)"
	@$(SERVE)

shell:
	@echo "Running a shell inside the container"
	@$(DEBUGSHELL)

.PHONY: dockerbuild build serve publish shell