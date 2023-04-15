#!/bin/bash
set -e

# Change permissions of the Docker socket file so the vscode user can use it
sudo chmod 666 /var/run/docker.sock

# Execute the original entrypoint
exec "$@"