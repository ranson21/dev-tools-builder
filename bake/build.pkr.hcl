packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}


locals {
  timeout = "5m"
  # Create version tags only if version is provided
  basic_tags     = var.version == "" ? ["basic"] : ["basic", "basic-${var.version}"]
  packer_tags    = var.version == "" ? ["packer"] : ["packer", "packer-${var.version}"]
  terraform_tags = var.version == "" ? ["terraform"] : ["terraform", "terraform-${var.version}"]
}

source "docker" "ubuntu" {
  image  = var.base_image
  commit = true
  changes = [
    "ENTRYPOINT [\"/usr/local/bin/entrypoint.sh\"]",
    "WORKDIR /workspace"
  ]
}

# Basic build with just Poetry
build {
  name    = "${var.image_name}-basic"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    script = "scripts/pre-setup.sh"
  }

  provisioner "shell" {
    script = "scripts/base-setup.sh"
  }

  provisioner "shell" {
    script  = "scripts/base-packages.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-poetry.sh"
    timeout = local.timeout
  }

  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /usr/local/bin/entrypoint.sh"]
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "docker-tag" {
    repository = var.image_repository
    tags       = local.basic_tags
  }
}

# Packer build with Packer, Docker, and GCloud
build {
  name    = "${var.image_name}-packer"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    script = "scripts/pre-setup.sh"
  }

  provisioner "shell" {
    script = "scripts/base-setup.sh"
  }

  provisioner "shell" {
    script  = "scripts/base-packages.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script           = "scripts/install-packer.sh"
    environment_vars = ["PACKER_VERSION=${var.packer_version}"]
    timeout          = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-docker.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script           = "scripts/install-gcloud.sh"
    environment_vars = ["GCLOUD_VERSION=${var.gcloud_version}"]
    timeout          = local.timeout
  }

  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /usr/local/bin/entrypoint.sh"]
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "docker-tag" {
    repository = var.image_repository
    tags       = local.packer_tags
  }
}

# Terraform build with Terraform, Terragrunt, and GCloud
build {
  name    = "${var.image_name}-terraform"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    script = "scripts/pre-setup.sh"
  }

  provisioner "shell" {
    script = "scripts/base-setup.sh"
  }

  provisioner "shell" {
    script  = "scripts/base-packages.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script           = "scripts/install-terraform.sh"
    environment_vars = ["TERRAFORM_VERSION=${var.terraform_version}"]
    timeout          = local.timeout
  }

  provisioner "shell" {
    script           = "scripts/install-terragrunt.sh"
    environment_vars = ["TERRAGRUNT_VERSION=${var.terragrunt_version}"]
    timeout          = local.timeout
  }

  provisioner "shell" {
    script           = "scripts/install-gcloud.sh"
    environment_vars = ["GCLOUD_VERSION=${var.gcloud_version}"]
    timeout          = local.timeout
  }

  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /usr/local/bin/entrypoint.sh"]
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "docker-tag" {
    repository = var.image_repository
    tags       = local.terraform_tags
  }
}

# NOTE: the previous "full" / all-in-one builder was removed 2026-04-28. It produced
# the :latest and :full tags, but those tags were never referenced by any pipeline
# (only :basic, :packer, and :terraform are consumed downstream). Keeping it caused
# 4 parallel docker-in-docker packer builds to starve a default Cloud Build VM,
# which hung the heaviest builder mid-`unzip` and timed out the whole image rebuild.
# If a future workflow needs a single image with everything, build it locally with
# `packer build` against a custom HCL or pull the targeted images side by side.