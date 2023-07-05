#!/bin/sh
docker rmi docker.base

echo "Building docker image..."
docker build --no-cache . -t docker.base
#docker build --squash --no-cache . -t docker.base
echo "Saving docker image..."
#docker save docker.base >/data/docker/docker.base.tar

