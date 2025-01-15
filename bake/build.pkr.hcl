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
  full_tags      = var.version == "" ? ["latest", "full"] : ["latest", "full", "full-${var.version}"]
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

# Full build with all tools
build {
  name    = var.image_name
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
    tags       = local.full_tags
  }
}