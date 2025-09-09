#!/bin/bash
set -e

echo "Building docker image..."
docker build --no-cache . -t loghi/docker.htr:latest
echo "Done"
