#!/bin/bash

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;

DIR=$1

for input_path in $(find $DIR/page/ -name '*.png');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
#  echo $filename
  curl -X POST -F "mask=@$base.png" -F "xml=@$base.xml" -F "identifier=$filename" http://localhost:8080/extract-baselines
done
