#!/bin/bash
set -ex
VERSION=${TERRAFORM_VERSION:-"1.5.7"}
echo "Installing Terraform version ${VERSION}..."
cd /download
wget --progress=bar:force "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip"
unzip "terraform_${VERSION}_linux_amd64.zip"
chmod +x terraform
mv terraform /usr/local/bin/
rm "terraform_${VERSION}_linux_amd64.zip"