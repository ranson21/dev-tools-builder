.PHONY: init validate test clean

# Configuration variables
PROJECT_ID := $(shell gcloud config get-value project)
LOCATION := us-central1
BUILDER_NAME := dev-tools-builder
BUILDER_TAG ?= latest  # Can be overridden by environment variable
BUILDER_BASE := $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME)
BUILDER_IMAGE_LATEST := $(BUILDER_BASE):latest

# Variables
COMMAND ?= help
IMAGE_TYPE ?= complete
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
	docker run --rm $(BUILDER_BASE) help

test_all:
	@echo "Testing all tool versions..."
	docker run --rm $(BUILDER_BASE) versions

test_command:
	@echo "Testing NPM version..."
	docker run --rm $(BUILDER_BASE)-$(IMAGE_TYPE) $(COMMAND)

# Push image(s)
.PHONY: push
push:
	@echo "Pushing all images in parallel..."
	@docker push $(BUILDER_BASE) 2>&1 | sed 's/^/complete: /' & \
	docker push $(BUILDER_BASE)-basic 2>&1 | sed 's/^/basic: /' & \
	docker push $(BUILDER_BASE)-packer 2>&1 | sed 's/^/packer: /' & \
	docker push $(BUILDER_BASE)-terraform 2>&1 | sed 's/^/terraform: /' & \
	wait

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

# List all versions of the image
.PHONY: list-versions
list-versions:
	@echo "Listing all versions of $(BUILDER_NAME)..."
	@gcloud artifacts docker tags list $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME) \
		--sort-by=~CREATE_TIME \
		--format="table[box](tag,version,metadata.create_time)"

# Show detailed information about a specific version
.PHONY: describe-version
describe-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make describe-version VERSION=<tag>"; \
		exit 1; \
	fi
	@echo "Showing details for version $(VERSION)..."
	@gcloud artifacts docker images describe $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):$(VERSION) \
		--format="yaml"

# Delete a specific version
.PHONY: delete-version
delete-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make delete-version VERSION=<tag>"; \
		exit 1; \
	fi
	@if [ "$(VERSION)" = "latest" ]; then \
		echo "Error: Cannot delete 'latest' tag as it's required for the build process"; \
		exit 1; \
	fi
	@echo "WARNING: About to delete version $(VERSION) of $(BUILDER_NAME)"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@gcloud artifacts docker tags delete $(LOCATION)-docker.pkg.dev/$(PROJECT_ID)/docker/$(BUILDER_NAME):$(VERSION) --quiet
	@echo "Version $(VERSION) deleted successfully"


clean:
	@echo "Cleaning up build artifacts..."
	rm -rf $(PACKER_DIR)/packer_cache
	docker rmi $(IMAGE_NAME) || true