#!/bin/bash

if [ -z $1 ]; then echo "first parameter should be the path of src of htr" && exit 1; fi;
SMT="$(realpath $1)"

echo "Change to directory of script..."
DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR_OF_SCRIPT

echo "Copy files for building docker..."
cp -r $SMT .
htr_folder=$(basename $SMT)

git --git-dir=$SMT/.git log --format="%H" -n 1 > $htr_folder/src/version_info

rm -rf ./$htr_folder/venv
rm -rf ./$htr_folder/checkpoints
rm -rf ./$htr_folder/__pycache__
rm -rf ./$htr_folder/.git
rm -rf ./$htr_folder/.idea
rm -rf ./$htr_folder/src/output
rm -rf ./$htr_folder/src/.idea
rm -rf ./$htr_folder/src/__pycache__
rm -rf ./$htr_folder/src/models
rm -rf ./$htr_folder/src/results
rm -rf ./$htr_folder/src/tiny
rm -rf ./$htr_folder/tiny
rm -rf ./$htr_folder/src/training*.txt
rm -rf ./$htr_folder/src/test15

#if [ -n "$2" ]; then
#	cp -rp $2 .
#	models_folder=$(basename $2)
#else
#	cp -rp ~/src/loghi-htr-models .
#	models_folder="loghi-htr-models"
#fi

echo "Building docker image..."
docker build --no-cache . -t loghi/docker.htr
#docker build . -t loghi/docker.htr
#docker build . -t docker.htr
#docker build --squash --no-cache . -t docker.htr

rm -rf ./$htr_folder
#rm -rf ./$models_folder
#docker system prune -f
