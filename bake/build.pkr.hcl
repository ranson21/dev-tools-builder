// build.pkr.hcl
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
}

source "docker" "ubuntu" {
  image  = var.base_image
  commit = true
  changes = [
    "ENTRYPOINT [\"/usr/local/bin/entrypoint.sh\"]",
    "WORKDIR /workspace"
  ]
}

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
    repository = "${var.image_repository}-basic"
    tags       = ["latest"]
  }
}

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
    script  = "scripts/install-packer.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-docker.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-gcloud.sh"
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
    repository = "${var.image_repository}-packer"
    tags       = ["latest"]
  }
}

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
    script  = "scripts/install-terraform.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-terragrunt.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-gcloud.sh"
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
    repository = "${var.image_repository}-terraform"
    tags       = ["latest"]
  }
}

build {
  name    = "${var.image_name}"
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
    script  = "scripts/install-packer.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-docker.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-terraform.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-terragrunt.sh"
    timeout = local.timeout
  }

  provisioner "shell" {
    script  = "scripts/install-gcloud.sh"
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
    repository = "${var.image_repository}"
    tags       = ["latest"]
  }
}