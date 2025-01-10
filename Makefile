.PHONY: init validate test clean

# Configuration variables
PROJECT_ID := $(shell gcloud config get-value project)
LOCATION := us-central1
BUILDER_NAME := dev-tools-builder
BUILDER_TAG ?= latest  # Can be overridden by environment variable
BUILDER_IMAGE_LATEST := $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):latest


# Variables
COMMAND ?= help
PACKER_DIR := bake
IMAGE_NAME := dev-tools-builder:latest

init:
	@echo "Initializing Packer plugins..."
	cd $(PACKER_DIR) && packer init .

validate:
	@echo "Validating Packer configuration..."
	cd $(PACKER_DIR) && packer validate .

test: build
	@echo "Testing Docker image basic functionality..."
	docker run --rm $(BUILDER_IMAGE_LATEST) help

test_all:
	@echo "Testing all tool versions..."
	docker run --rm $(BUILDER_IMAGE_LATEST) versions

test_command:
	@echo "Testing NPM version..."
	docker run --rm $(BUILDER_IMAGE_LATEST) $(COMMAND)

# Push image(s)
.PHONY: push
push:
	@echo "Pushing latest tag..."
	@docker push $(BUILDER_IMAGE_LATEST)
	@if [ "$(BUILDER_TAG)" != "latest" ]; then \
		echo "Pushing version $(BUILDER_TAG)..."; \
		docker push $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):$(BUILDER_TAG); \
	fi

# Refresh Docker credentials
.PHONY: refresh
refresh:
	@echo "Refreshing credentials..."
	@docker logout https://$(LOCATION)-docker.pkg.dev
	@gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://$(LOCATION)-docker.pkg.dev

# Configure Docker authentication
.PHONY: configure-docker
configure-docker:
	@echo "Configuring Docker authentication..."
	@gcloud auth configure-docker $(LOCATION)-docker.pkg.dev

.PHONY: build
build: init validate
	@echo "Building Docker image..."
	@cd $(PACKER_DIR) && packer build -var="image_repository=$(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME)" .
	@if [ "$(BUILDER_TAG)" != "latest" ] && [ -n "$(BUILDER_TAG)" ]; then \
		echo "Tagging version $(BUILDER_TAG)..."; \
		docker tag $(BUILDER_IMAGE_LATEST) $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):$(BUILDER_TAG); \
	fi

# All-in-one command to build and push
.PHONY: deploy
deploy: configure-docker build push
	@if [ "$(BUILDER_TAG)" != "latest" ]; then \
		echo "Successfully built and pushed images:"; \
		echo "  - $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):$(BUILDER_TAG)"; \
		echo "  - $(BUILDER_IMAGE_LATEST)"; \
	else \
		echo "Successfully built and pushed image:"; \
		echo "  - $(BUILDER_IMAGE_LATEST)"; \
	fi

clean:
	@echo "Cleaning up build artifacts..."
	rm -rf $(PACKER_DIR)/packer_cache
	docker rmi $(IMAGE_NAME) || true