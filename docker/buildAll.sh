#!/bin/bash

CURRENT=$(pwd)

DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR_OF_SCRIPT

BASE="$(realpath $DIR_OF_SCRIPT/..)"

# TODO Maybe this needs to also update the submodules (Rutger?)
cd $BASE
git pull
git submodule update --recursive --remote

#cd $BASE/prima-core-libs
#git pull
#cd $BASE/loghi-tooling
#git pull
#cd $BASE/loghi-htr
#git pull
#cd $BASE/laypa
#git pull

cd $DIR_OF_SCRIPT

echo "building docker.base"
cd docker.base
./buildImage.sh
cd ..
echo "building docker.loghi-tooling"
cd docker.loghi-tooling/
./buildImage.sh $BASE/prima-core-libs/ $BASE/loghi-tooling/
cd ..
echo "building docker.htr"
cd docker.htr
./buildImage.sh $BASE/loghi-htr
cd ..
echo "building docker.laypa"
cd docker.laypa
./buildImage.sh $BASE/laypa
cd ..
