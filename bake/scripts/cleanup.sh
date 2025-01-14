#!/bin/bash
set -ex
echo 'Cleaning up...'
rm -rf /download
rm -rf /root/.cache /root/.npm /root/.config /tmp/* /var/tmp/* /var/cache/apk/*
rm -rf /usr/share/man /usr/share/doc