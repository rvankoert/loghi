#!/bin/bash

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;

DIR=$1

for input_path in $(find $DIR/ -name '*.jpg');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
#  echo $filename
  curl -X POST -F "image=@$input_path" -F "page=@$DIR/page/$filename.xml" -F "identifier=$filename" -F "output_type=png" -F "channels=4" http://localhost:8080/cut-from-image-based-on-page-xml-new

done
