#!/bin/bash
set -ex
echo 'Downloading Terragrunt...'
cd /download
wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.12/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
mv terragrunt_linux_amd64 /usr/local/bin/terragrunt