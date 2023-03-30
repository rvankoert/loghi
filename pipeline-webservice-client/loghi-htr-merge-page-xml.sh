#!/bin/bash

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;

page=$1
results=$2
htr_config=$3
filename=$(basename -- "$page")
filename="${filename%.*}"

echo $filename
curl -X POST -F "page=@$page" -F "results=@$results" -F "htr-config=@$htr_config" -F "identifier=$filename" http://localhost:8080/loghi-htr-merge-page-xml
