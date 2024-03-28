#!/bin/bash

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;

DIR=$1

for input_path in $(find $DIR/ -name '*.jpg');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
  curl -X POST -F image=@$input_path -F "identifier=$filename" -F model=ijsberg 'http://localhost:5000/predict'
done
