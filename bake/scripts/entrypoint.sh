#!/bin/bash

source /root/.bashrc

# If the command is version-related, use the test Makefile
if [ "$1" = "version" ] || [ "$1" = "versions" ] || [[ "$1" = *"_version" ]] || [ "$1" = "help" ]; then
    cd /usr/local/build-tools && make "$@"
else
    # Otherwise, use the project's Makefile
    cd /workspace && make "$@"
fi