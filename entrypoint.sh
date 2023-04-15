#!/bin/bash
set -e

# Change permissions of the Docker socket file
sudo chmod 666 /var/run/docker.sock

# Execute the original entrypoint
exec "$@"