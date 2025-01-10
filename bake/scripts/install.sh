#!/bin/sh
set -e

# Create directories
mkdir -p /usr/local/build-tools /workspace /usr/local/gcloud

# Install runtime dependencies that we want to keep
apk add --no-cache \
    bash \
    git \
    make \
    python3 \
    py3-pip \
    python3-dev \
    py3-virtualenv \
    nodejs \
    npm

# Install build-only dependencies that will be removed later
apk add --no-cache --virtual .build-deps \
    build-base \
    curl \
    wget \
    unzip \
    gnupg

# Install Poetry in a virtual environment
python3 -m venv /opt/poetry
/opt/poetry/bin/pip install --no-cache-dir poetry
ln -s /opt/poetry/bin/poetry /usr/local/bin/poetry

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/1.10.4/terraform_1.10.4_linux_amd64.zip && \
unzip -q terraform_1.10.4_linux_amd64.zip && \
mv terraform /usr/local/bin/ && \
rm terraform_1.10.4_linux_amd64.zip

# Install Terragrunt
wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64 && \
chmod +x terragrunt_linux_amd64 && \
mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Install Google Cloud SDK
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON=/usr/bin/python3
mkdir -p /usr/local/gcloud

wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-505.0.0-linux-x86_64.tar.gz
tar -xzf google-cloud-cli-505.0.0-linux-x86_64.tar.gz -C /usr/local/gcloud
/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --command-completion=false --additional-components="" --rc-path=/etc/profile.d/gcloud.sh && rm -f google-cloud-cli-459.0.0-linux-x86_64.tar.gz

# Create symlinks for gcloud tools
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq


# Aggressive cleanup
rm -rf /root/.cache
rm -rf /root/.npm
rm -rf /root/.config
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/apk/*
rm -rf /usr/share/man
rm -rf /usr/share/doc
rm -rf /usr/local/gcloud/google-cloud-sdk/.install
rm -rf /usr/local/gcloud/google-cloud-sdk/platform
find /usr/local -type f -name "*.pyc" -delete
find /usr/local -type d -name "__pycache__" -exec rm -r {} +

# Remove build dependencies that aren't needed for runtime
apk del .build-deps

# Configure gcloud to minimize space
gcloud config set disable_usage_reporting true
gcloud config set component_manager/disable_update_check true
# apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential make git curl wget unzip python3 python3-pip nodejs npm apt-transport-https ca-certificates gnupg lsb-release

# # Install Poetry
# curl -sSL https://install.python-poetry.org | python3 -

# # Install Terraform
# wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
# apt-get update
# apt-get install -y terraform

# # Install Terragrunt
# wget https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
# chmod +x terragrunt_linux_amd64
# mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# # Install Google Cloud SDK
# echo \"deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main\" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# apt-get update
# apt-get install -y google-cloud-sdk

# # Create directories
# mkdir -p /usr/local/build-tools /workspace

# # Clean up
# apt-get clean
# rm -rf /var/lib/apt/lists/*
# rm -rf /tmp/*
# rm -rf /var/tmp/*