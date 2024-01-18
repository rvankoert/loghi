#!/bin/bash
VERSION=1.3.8

if [ -z $1 ]; then echo "please provide path to images and pagexml to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"" && exit 1; fi;
if [ -z $2 ]; then echo "please provide output path" && exit 1; fi;
if [ -z $3 ]; then
        echo "setting numthreads=4"
        numthreads=4
else
        numthreads=$3
        echo "setting numthreads=$numthreads"
fi;

#directory containing images and pagexml. The pageXML must be one level deeper than the images in a directory called "page"
mkdir -p $2
inputdir=$(realpath $1/)
outputdir=$(realpath $2/)
filelist=$outputdir/training_all.txt
filelisttrain=$outputdir/training_all_train.txt
filelistval=$outputdir/training_all_val.txt
#90 percent for training
trainsplit=90
DOCKERLOGHITOOLING=loghi/docker.loghi-tooling:$VERSION
INCLUDETEXTSTYLES=" -include_text_styles " # translate the text styles defined in transkribus to loghi htr training data with text styles
SKIP_UNCLEAR=" -skip_unclear " # skip all lines that have a tag unclear

echo $inputdir
echo $outputdir
echo $filelist
echo $filelisttrain
echo $filelistval

find $inputdir -name '*.done' -exec rm {} \;

echo "inputfiles: " `find $inputdir|wc -l`


#echo /home/rutger/src/opencvtest2/agenttesseract/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $inputdir -outputbase $outputdir -channels 4 -output_type png -write_text_contents -threads $numthreads
#/home/rutger/src/opencvtest2/agenttesseract/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $inputdir -outputbase $outputdir -channels 4 -output_type png -write_text_contents -threads $numthreads
echo docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $inputdir/:$inputdir/ -v $outputdir:$outputdir $DOCKERLOGHITOOLING \
  /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $inputdir -outputbase $outputdir -channels 4 -output_type png -write_text_contents -threads $numthreads $INCLUDETEXTSTYLES -use_2013_namespace
docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $inputdir/:$inputdir/ -v $outputdir:$outputdir $DOCKERLOGHITOOLING \
  /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $inputdir -outputbase $outputdir -channels 4 -output_type png -write_text_contents -threads $numthreads $INCLUDETEXTSTYLES -no_page_update $SKIP_UNCLEAR -use_2013_namespace

echo "outputfiles: " `find $outputdir|wc -l`


count=0
> $filelist
for input_path in $(find $outputdir -name '*.png');
do
        filename=$(basename -- "$input_path")
        filename="${filename%.*}"
        base="${input_path%.*}"
#        text=`cat $base.box|colrm 2|tr -d '\n'`
        text=`cat $base.txt`
        echo -e "$input_path\t$text" >>$filelist
done


shuf $filelist | split -l $(( $(wc -l <$filelist) * $trainsplit / 100 )); mv xab $filelistval; mv xaa $filelisttrain
