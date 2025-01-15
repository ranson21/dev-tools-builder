#!/bin/bash
set -ex
echo 'Installing base packages...'
apk update
apk add --no-cache bash wget curl git make python3 py3-pip nodejs npm jq
