#!/bin/bash
set -ex
echo 'Installing Poetry...'
cd /download
curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local python3 -
echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc