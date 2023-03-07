#!/bin/bash

# /media/rutger/HDI0002/train_data_republicrandom/

if [ -z $1 ]; then echo "please provide path to line images " && exit 1; fi;

DIR=$1

for input_path in $(find $DIR -name '*.png');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
  echo $filename
  curl -X POST -F "image=@$input_path" -F "identifier=$filename" http://localhost:5000/predict
done
