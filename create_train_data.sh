#!/bin/bash

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;
if [ -z $2 ]; then echo "please provide output path" && exit 1; fi;
if [ -z $3 ]; then
        echo "setting numthreads=4"
        numthreads=4
else 
        numthreads=$3
        echo $numthreads
fi;

#directory containing images and pagexml. The pageXML must be one level deeper than the images in a directory called "page"
inputdir=$1/
outputdir=$2/
filelist=$outputdir/training_all.txt
filelisttrain=$outputdir/training_all_train.txt
filelistval=$outputdir/training_all_val.txt
#90 percent for training
trainsplit=90
DOCKERLOGHITOOLING=loghi/docker.loghi-tooling

echo $inputdir
echo $outputdir
echo $filelist
echo $filelisttrain
echo $filelistval

find $inputdir -name '*.done' -exec rm {} \;

mkdir -p $outputdir
echo "inputfiles: " `find $inputdir|wc -l`


docker run --rm -u $(id -u ${USER}):$(id -g ${USER}) -v $inputdir/:$inputdir/ -v $outputdir:$outputdir $DOCKERLOGHITOOLING \
  /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $inputdir -outputbase $outputdir -channels 4 -output_type png -write_text_contents -threads $numthreads

echo "outputfiles: " `find $outputdir|wc -l`


count=0
> $filelist
for input_path in $(find $outputdir -name '*.png');
do
        filename=$(basename -- "$input_path")
        filename="${filename%.*}"
        base="${input_path%.*}"
        text=`cat $base.box|colrm 2|tr -d '\n'`
        echo -e "$input_path\t$text" >>$filelist
done


shuf $filelist | split -l $(( $(wc -l <$filelist) * $trainsplit / 100 )); mv xab $filelistval; mv xaa $filelisttrain

