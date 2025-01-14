#!/bin/bash
set -ex
echo 'Installing Terraform...'
cd /download
wget --progress=bar:force https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip
chmod +x terraform
mv terraform /usr/local/bin/
rm terraform_1.5.7_linux_amd64.zip