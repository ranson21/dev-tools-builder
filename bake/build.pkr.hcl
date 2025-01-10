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

  # First install a shell that can run the script
  provisioner "shell" {
    inline = [
      "apk add --no-cache bash"
    ]
  }

  # provisioner "file" {
  #   source      = "scripts/install.sh"
  #   destination = "/usr/local/bin/install.sh"
  # }

  # # Make it executable and run it with bash explicitly
  # provisioner "shell" {
  #   inline = [
  #     "chmod +x /usr/local/bin/install.sh",
  #     "bash /usr/local/bin/install.sh"
  #   ]
  # }
  provisioner "shell" {
    inline = [
      # Stage 1: Download and prepare binaries
      "mkdir -p /download /usr/local/bin /usr/local/build-tools /workspace /usr/local/gcloud",

      # Install minimal runtime dependencies
      "apk add --no-cache curl bash git make python3 py3-pip nodejs npm py3-six py3-httplib2 py3-yaml py3-requests py3-google-auth",

      # Download tools in parallel
      "cd /download && wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64",
      "cd /download && wget -q https://releases.hashicorp.com/terraform/1.10.4/terraform_1.10.4_linux_amd64.zip",
      "cd /download && wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz",

      # Extract and prepare binaries
      "cd /download && unzip -q terraform_1.10.4_linux_amd64.zip && chmod +x terraform",
      "cd /download && chmod +x terragrunt_linux_amd64",
      "cd /download && tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud",

      # Install google cloud SDK
      "/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --command-completion=false --rc-path=/etc/profile.d/gcloud.sh && rm -f google-cloud-cli-505.0.0-linux-x86_64.tar.gz",

      # Create symlinks for gcloud tools
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil",
      "ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq",

      # Install Poetry with minimal dependencies
      "curl -sSL https://install.python-poetry.org | python3 -",
      "echo 'export PATH=\"/root/.local/bin:$PATH\"' >> /root/.bashrc",
      "source /root/.bashrc && poetry --version",

      # Move binaries to final location
      "mv /download/terraform /usr/local/bin/",
      "mv /download/terragrunt_linux_amd64 /usr/local/bin/terragrunt",

      # Remove all downloaded files
      "rm -rf /download",

      # Configure gcloud
      "gcloud config set disable_usage_reporting true",
      "gcloud config set component_manager/disable_update_check true",

      # Aggressive cleanup
      "rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*",
      "rm -rf /usr/share/man /usr/share/doc",

      # Print final sizes for verification
      "echo 'Final directory sizes:' && du -sh /usr/local/*",
    ]
  }

  # Copy the test Makefile into the container
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

  post-processor "docker-tag" {
    repository = var.image_repository
    tags       = ["latest"]
  }
}