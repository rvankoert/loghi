#!/bin/bash

if [ -z $1 ]; then echo "please provide path to pagexml whiches text lines should be split into words. " && exit 1; fi;

DIR=$1

#for input_path in $(find $DIR/ -name '*.jpg');
for input_path in $(find $DIR -maxdepth 1 -type f -name "*.xml");
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
  #echo $filename
  curl -X POST -F "identifier=$filename" -F "xml=@$input_path" http://localhost:8080/split-page-xml-text-line-into-words
done
