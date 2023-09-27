#!/bin/bash

# Configuration for HTR mode selection
HTRLOGHI=1

# Model configuration
HTRLOGHIMODELHEIGHT=64
HTRBASEMODEL=/src/loghi-htr-models/model-new12-generic_synthetic
USEBASEMODEL=0

# Define a VGSL model
# This is equivalent to model10 in the model library
HTRNEWMODEL="None,64,None,3 Cr3,3,24 Bn Mp2,2,2,2 Cr3,3,48 Bn Mp2,2,2,2 Cr3,3,96 Bn Cr3,3,96 Bn Mp2,2,2,2 Rc Bg256 Bg256 Bg256 Bg256 Bg256 O1s92"
channels=3

GPU=0

# Dataset and training configuration
listdir=/home/tim/Downloads/ijsberg-split/
trainlist=$listdir/training_mini.txt
validationlist=$listdir/training_all_val.txt
datadir=/scratch/republicprint
charlist=/data/htr_train_notdeeds/output_charlist.charlist
epochs=1
height=$HTRLOGHIMODELHEIGHT
multiply=1
batch_size=4
model_name=myfirstmodel
learning_rate=0.0003

# DO NOT EDIT BELOW THIS LINE
tmpdir=$(mktemp -d)
mkdir $tmpdir/output

BASEMODEL=""
if [[ $USEBASEMODEL -eq 1 ]]; then
    BASEMODEL=" --existing_model "$HTRBASEMODEL
fi

# LoghiHTR option
if [[ $HTRLOGHI -eq 1 ]]; then
    echo "Starting Loghi HTR"
    docker run --gpus all --rm  -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -ti \
        -v /tmp:/tmp \
        -v $tmpdir:$tmpdir \
        -v $listdir:$listdir \
        -v $datadir:$datadir \
        loghi/docker.htr python3 /src/loghi-htr/src/main.py \
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
        --beam_width 10 \
        --model "$HTRNEWMODEL" \
        --decay_steps 5000 \
        --multiply $multiply \
        --output $listdir \
        --model_name $model_name \
        --output_charlist $tmpdir/output_charlist.charlist \
        --output $tmpdir/output
fi

echo "Results can be found at:"
echo $tmpdir

