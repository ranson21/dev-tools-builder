#!/bin/bash
set -ex
echo 'Starting Packer installation...'
cd /download
wget --progress=bar:force https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip
unzip -o packer_1.11.2_linux_amd64.zip
chmod +x packer
mv packer /usr/local/bin/
rm -f packer_1.11.2_linux_amd64.zip