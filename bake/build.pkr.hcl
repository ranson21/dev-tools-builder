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

// Base source configuration
source "docker" "ubuntu" {
  image  = var.base_image
  commit = true
  changes = [
    "ENTRYPOINT [\"/usr/local/bin/entrypoint.sh\"]",
    "WORKDIR /workspace"
  ]
}

// Basic tools build
build {
  name    = "${var.image_name}-basic"
  sources = ["source.docker.ubuntu"]

  // Create directories
  provisioner "shell" {
    inline = [
      "set -ex",
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace"
    ]
  }

  // Install base packages
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing base packages...'",
      "apk update",
      "apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm"
    ]
  }

  # Copy the test Makefile
  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  // Set up entrypoint
  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "chmod +x /usr/local/bin/entrypoint.sh"
    ]
  }

  // Cleanup
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Cleaning up...'",
      "rm -rf /download",
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc"
    ]
  }

  post-processor "docker-tag" {
    repository = "${var.image_repository}-basic"
    tags       = ["latest"]
  }
}

// Packer tools build
build {
  name    = "${var.image_name}-packer"
  sources = ["source.docker.ubuntu"]

  // Base setup
  provisioner "shell" {
    inline = [
      "set -ex",
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace /usr/local/gcloud"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing base packages...'",
      "apk update",
      "apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm docker"
    ]
  }

  // Install Packer
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Starting Packer installation...'",
      "cd /download",
      "wget --progress=bar:force https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip",
      "unzip -o packer_1.11.2_linux_amd64.zip",
      "chmod +x packer",
      "mv packer /usr/local/bin/",
      "rm -f packer_1.11.2_linux_amd64.zip"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Google Cloud SDK...'",
      "cd /download",
      "wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz",
      "tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud",
      "rm google-cloud-cli-505.0.0-linux-x86_64.tar.gz"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing Google Cloud SDK...'",
      "/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --rc-path=/etc/profile.d/gcloud.sh",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq"
    ]
  }

  # Copy the test Makefile
  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  // Set up entrypoint and cleanup
  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "chmod +x /usr/local/bin/entrypoint.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Cleaning up...'",
      "rm -rf /download",
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc"
    ]
  }

  post-processor "docker-tag" {
    repository = "${var.image_repository}-packer"
    tags       = ["latest"]
  }
}

// Terraform tools build
build {
  name    = "${var.image_name}-terraform"
  sources = ["source.docker.ubuntu"]

  // Base setup
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace /usr/local/gcloud"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing base packages...'",
      "apk update",
      "apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm"
    ]
  }

  // Install Terraform
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Terraform...'",
      "cd /download",
      "wget -q https://releases.hashicorp.com/terraform/1.10.4/terraform_1.10.4_linux_amd64.zip",
      "unzip -q terraform_1.10.4_linux_amd64.zip",
      "chmod +x terraform",
      "mv terraform /usr/local/bin/",
      "rm terraform_1.10.4_linux_amd64.zip"
    ]
  }

  // Install Terragrunt
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Terragrunt...'",
      "cd /download",
      "wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64",
      "chmod +x terragrunt_linux_amd64",
      "mv terragrunt_linux_amd64 /usr/local/bin/terragrunt"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Google Cloud SDK...'",
      "cd /download",
      "wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz",
      "tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud",
      "rm google-cloud-cli-505.0.0-linux-x86_64.tar.gz"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing Google Cloud SDK...'",
      "/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --rc-path=/etc/profile.d/gcloud.sh",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq"
    ]
  }

  # Copy the test Makefile
  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  // Set up entrypoint and cleanup
  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "chmod +x /usr/local/bin/entrypoint.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Cleaning up...'",
      "rm -rf /download",
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc"
    ]
  }

  post-processor "docker-tag" {
    repository = "${var.image_repository}-terraform"
    tags       = ["latest"]
  }
}

// Complete tools build
build {
  name    = "${var.image_name}-complete"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace /usr/local/gcloud"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing base packages...'",
      "apk update",
      "apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm py3-six py3-httplib2 py3-yaml py3-requests py3-google-auth docker"
    ]
  }

  // Install all tools
  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Starting Packer installation...'",
      "cd /download",
      "wget --progress=bar:force https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip",
      "unzip -o packer_1.11.2_linux_amd64.zip",
      "chmod +x packer",
      "mv packer /usr/local/bin/",
      "rm -f packer_1.11.2_linux_amd64.zip"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing Terraform...'",
      "cd /download",
      "wget --progress=bar:force https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip",
      "unzip terraform_1.5.7_linux_amd64.zip",
      "chmod +x terraform",
      "mv terraform /usr/local/bin/",
      "rm terraform_1.5.7_linux_amd64.zip"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Terragrunt...'",
      "cd /download",
      "wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64",
      "chmod +x terragrunt_linux_amd64",
      "mv terragrunt_linux_amd64 /usr/local/bin/terragrunt"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Downloading Google Cloud SDK...'",
      "cd /download",
      "wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz",
      "tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud",
      "rm google-cloud-cli-505.0.0-linux-x86_64.tar.gz"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing Google Cloud SDK...'",
      "/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --rc-path=/etc/profile.d/gcloud.sh",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq"
    ]
  }

  provisioner "shell" {
    timeout = local.timeout
    inline = [
      "set -ex",
      "echo 'Installing Poetry...'",
      "cd /download",
      "curl -sSL https://install.python-poetry.org | python3 -",
      "echo 'export PATH=\"/root/.local/bin:$PATH\"' >> /root/.bashrc"
    ]
  }

  # Copy the test Makefile
  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  // Set up entrypoint and cleanup
  provisioner "file" {
    source      = "scripts/entrypoint.sh"
    destination = "/usr/local/bin/entrypoint.sh"
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "chmod +x /usr/local/bin/entrypoint.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Cleaning up...'",
      "rm -rf /download",
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc"
    ]
  }

  post-processor "docker-tag" {
    repository = "${var.image_repository}-complete"
    tags       = ["latest"]
  }
}