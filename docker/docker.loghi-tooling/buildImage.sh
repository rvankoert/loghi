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
#docker-compose build
#docker build --squash --no-cache . -t docker.loghi-tooling
docker build --no-cache --squash . -t docker.loghi-tooling
#echo "Saving docker image..."
#mkdir -p /data
#docker save dockeranalyzerwebservice_analyzerwebservice:latest > /data/docker/docker.analyzerwebservice.tar

#sudo docker-squash -i /data/docker/docker.analyzerwebservice.tar -o /data/docker/docker.analyzerwebservice.tar.squashed
#mv /data/docker/docker.analyzerwebservice.tar.squashed /data/docker/docker.analyzerwebservice.tar


#echo "Copying docker image... to murphy"
#scp /data/docker/docker.analyzerwebservice.tar rutgervk@hi26.huygens.knaw.nl:/data/pb2/
#scp /data/docker/docker.analyzerwebservice.tar rutgerk@murphy:/allround/docker-images/

#echo "Loading docker image on server..."
#ssh rutgervk@hi26.huygens.knaw.nl /home/rutgervk/loadanalyzerwebservice.sh

echo "cleaning up!"
rm -rf prima-core-libs
rm -rf loghi-tooling

docker system prune -f
