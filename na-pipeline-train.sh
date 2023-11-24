#!/bin/bash
VERSION=1.3.4
set -e

# Configuration for HTR mode selection
HTRLOGHI=1

# Model configuration
HTRLOGHIMODELHEIGHT=64
HTRBASEMODEL=PATH_TO_HTR_BASE_MODEL
#set to 1 to actually use basemodel, 0 to not use basemodel
USEBASEMODEL=0

# Define a VGSL model
# This is equivalent to model10 in the model library
HTRNEWMODEL="None,64,None,3 Cr3,3,24 Bn Mp2,2,2,2 Cr3,3,48 Bn Mp2,2,2,2 Cr3,3,96 Bn Cr3,3,96 Bn Mp2,2,2,2 Rc Bl256 Bl256 Bl256 Bl256 Bl256 O1s92"
# set channels to 1 to process input as grayscale, 3 for color, 4 for color and mask
channels=4

GPU=0

# Dataset and training configuration
listdir=PATH_TO_LISTDIR
trainlist=$listdir/training_all_train.txt
validationlist=$listdir/training_all_val.txt
datadir=/scratch/republicprint
charlist=PATH_TO_EXISTING_CHARLIST_FINETUNE
epochs=1
height=$HTRLOGHIMODELHEIGHT
multiply=1
# best not to go lower than 2 with batchsize
batch_size=4
model_name=myfirstmodel
learning_rate=0.0003

# DO NOT EDIT BELOW THIS LINE
tmpdir=$(mktemp -d)

#PLACEHOLDER#

mkdir -p $tmpdir/output

BASEMODEL=""
BASEMODELDIR=""
if [[ $USEBASEMODEL -eq 1 ]]; then
    BASEMODEL=" --existing_model "$HTRBASEMODEL
    BASEMODELDIR="-v $(dirname "${HTRBASEMODEL}"):$(dirname "${HTRBASEMODEL}")"

fi

# LoghiHTR option
if [[ $HTRLOGHI -eq 1 ]]; then
    echo "Starting Loghi HTR"
    echo docker run --gpus all --rm  -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -ti \
	$BASEMODELDIR \
        -v $tmpdir:$tmpdir \
        -v $listdir:$listdir \
        -v $datadir:$datadir \
        loghi/docker.htr:$VERSION python3 /src/loghi-htr/src/main.py \
        --do_train \
        --train_list $trainlist \
        --do_validate \
        --validation_list $validationlist \
        --learning_rate $learning_rate \
        --channels $channels \
        --batch_size $batch_size \
        --epochs $epochs \
        --gpu $GPU \
        --height $height \
        --use_mask \
        --seed 1 \
        --beam_width 1 \
        --model "$HTRNEWMODEL" \
        --multiply $multiply \
        --output $listdir \
        --model_name $model_name \
        --output_charlist $tmpdir/output_charlist.charlist \
        --output $tmpdir/output $BASEMODEL
    docker run --gpus all --rm  -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -ti \
	$BASEMODELDIR \
        -v $tmpdir:$tmpdir \
        -v $listdir:$listdir \
        -v $datadir:$datadir \
        loghi/docker.htr:$VERSION python3 /src/loghi-htr/src/main.py \
        --do_train \
        --train_list $trainlist \
        --do_validate \
        --validation_list $validationlist \
        --learning_rate $learning_rate \
        --channels $channels \
        --batch_size $batch_size \
        --epochs $epochs \
        --gpu $GPU \
        --height $height \
        --use_mask \
        --seed 1 \
        --beam_width 1 \
        --model "$HTRNEWMODEL" \
        --multiply $multiply \
        --output $listdir \
        --model_name $model_name \
        --output_charlist $tmpdir/output_charlist.charlist \
        --output $tmpdir/output $BASEMODEL
fi

echo "Results can be found at:"
echo $tmpdir

