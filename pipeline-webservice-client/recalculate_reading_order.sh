#!/bin/bash

if [ -z $1 ]; then echo "please provide path to pagexml to be reordered. " && exit 1; fi;

DIR=$1

#for input_path in $(find $DIR/ -name '*.jpg');
for input_path in $(find $DIR -maxdepth 1 -type f -name "*.xml");
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
  #echo $filename
  curl -v -X POST -F "identifier=$filename" -F "page=@$input_path" -F "border_margin=200" http://localhost:8080/recalculate-reading-order-new
done
