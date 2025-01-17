#!/bin/bash
set -ex
VERSION=${GCLOUD_VERSION:-"505.0.0"}
echo "Installing Google Cloud SDK version ${VERSION}..."
cd /download
wget -q "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${VERSION}-linux-x86_64.tar.gz"
tar -xzf "google-cloud-cli-${VERSION}-linux-x86_64.tar.gz" -C /usr/local/gcloud
rm "google-cloud-cli-${VERSION}-linux-x86_64.tar.gz"

echo 'Installing Google Cloud SDK...'
/usr/local/gcloud/google-cloud-sdk/install.sh --quiet --path-update=false --usage-reporting=false --rc-path=/etc/profile.d/gcloud.sh
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil
ln -sf /usr/local/gcloud/google-cloud-sdk/bin/bq /usr/local/bin/bq