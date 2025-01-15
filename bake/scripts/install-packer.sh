#!/bin/bash
set -ex
VERSION=${PACKER_VERSION:-"1.11.2"}
echo "Installing Packer version ${VERSION}..."
cd /download
wget --progress=bar:force "https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_linux_amd64.zip"
unzip -o "packer_${VERSION}_linux_amd64.zip"
chmod +x packer
mv packer /usr/local/bin/
rm -f "packer_${VERSION}_linux_amd64.zip"