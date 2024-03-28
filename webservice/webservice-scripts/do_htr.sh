#!/bin/bash

# /media/rutger/HDI0002/train_data_republicrandom/

if [ -z $1 ]; then echo "please provide path to line images " && exit 1; fi;

DIR=$1

for input_path in $(find $DIR -name '*.png');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  base="${input_path%.*}"
  group_id=`echo $filename|cut -d "-" -f1`
  echo $filename
  curl -X POST -F "image=@$input_path" -F "group_id=$group_id" -F "identifier=$filename" http://localhost:5001/predict
done
