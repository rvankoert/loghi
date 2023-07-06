#!/bin/bash

if [ -z $1 ]; then echo "first parameter should be the path of prima-core-libs" && exit 1; fi;
if [ -z $2 ]; then echo "second parameter should be the path of loghi-tooling" && exit 1; fi;

PRIMACORELIBS="$(realpath $1)"
LOGHITOOLING="$(realpath $2)"

echo "Change to directory of script..."
DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR_OF_SCRIPT

echo "Copy files for building docker..."
cp -r $PRIMACORELIBS .
cp -r $LOGHITOOLING .

rm -rf ./prima-core-libs/.git
rm -rf ./prima-core-libs/target
rm -rf ./prima-core-libs/java/PrimaBasic/target
rm -rf ./loghi-tooling/.git
rm -rf ./loghi-tooling/target
rm -rf ./loghi-tooling/layoutanalyzer/target
rm -rf ./loghi-tooling/minions/target
rm -rf ./loghi-tooling/layoutds/target
rm -rf ./loghi-tooling/layoutanalyzer/src/test/resources/in/*.png

echo "Building docker image..."
#docker build --squash --no-cache . -t loghi/docker.loghi-tooling
docker build --no-cache --squash . -t loghi/docker.loghi-tooling
#echo "Saving docker image..."

echo "cleaning up!"
rm -rf prima-core-libs
rm -rf loghi-tooling

docker system prune -f
