packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
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
  name    = var.image_name
  sources = ["source.docker.ubuntu"]

  # Create directories
  provisioner "shell" {
    inline = [
      "set -ex",
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace /usr/local/gcloud"
    ]
  }

  # Install base packages
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Installing base packages...'",
      "apk update",
      "apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm py3-six py3-httplib2 py3-yaml py3-requests py3-google-auth docker"
    ]
  }

  # Download Terragrunt
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Downloading Terragrunt...'",
      "cd /download",
      "wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64",
      "chmod +x terragrunt_linux_amd64",
      "mv terragrunt_linux_amd64 /usr/local/bin/terragrunt"
    ]
  }

  # Download and install Terraform
  provisioner "shell" {
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

  # Download and install Google Cloud SDK
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Downloading Google Cloud SDK...'",
      "cd /download",
      "wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz",
      "echo 'Extracting Google Cloud SDK...'",
      "tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud",
      "rm google-cloud-cli-505.0.0-linux-x86_64.tar.gz"
    ]
  }

  # Install Google Cloud SDK
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Installing Google Cloud SDK...'",
      "/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --rc-path=/etc/profile.d/gcloud.sh"
    ]
  }

  # Create Google Cloud SDK symlinks
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Creating Google Cloud SDK symlinks...'",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq"
    ]
  }

  # Download and install Packer
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Starting Packer installation...'",
      "cd /download",
      # Remove -q from wget to see progress
      "echo 'Downloading Packer binary...'",
      "wget --progress=bar:force https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip || { echo 'Download failed'; exit 1; }",
      "echo 'Verifying download...'",
      "ls -lh packer_1.11.2_linux_amd64.zip",
      "echo 'Extracting Packer...'",
      "unzip -o packer_1.11.2_linux_amd64.zip || { echo 'Unzip failed'; exit 1; }",
      "echo 'Setting permissions...'",
      "chmod +x packer",
      "echo 'Moving Packer to final location...'",
      "mv packer /usr/local/bin/",
      "echo 'Cleaning up...'",
      "rm -f packer_1.11.2_linux_amd64.zip",
      "echo 'Verifying Packer installation...'",
      "/usr/local/bin/packer --version || { echo 'Packer verification failed'; exit 1; }"
    ]
  }

  # Install Poetry
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Installing Poetry...'",
      "cd /download",
      "curl -sSL https://install.python-poetry.org | python3 -",
      "echo 'export PATH=\"/root/.local/bin:$PATH\"' >> /root/.bashrc"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "set -ex",
      "echo 'Cleaning up...'",
      "rm -rf /download",
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc"
    ]
  }

  # Copy the test Makefile
  provisioner "file" {
    source      = "test/Makefile"
    destination = "/usr/local/build-tools/Makefile"
  }

  # Copy and set up entrypoint script
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

  post-processor "docker-tag" {
    repository = var.image_repository
    tags       = ["latest"]
  }
}