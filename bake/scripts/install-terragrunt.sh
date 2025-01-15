#!/bin/bash
set -ex
VERSION=${TERRAGRUNT_VERSION:-"v0.54.12"}
echo "Installing Terragrunt version ${VERSION}..."
cd /download
wget -q "https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64"
chmod +x terragrunt_linux_amd64
mv terragrunt_linux_amd64 /usr/local/bin/terragrunt