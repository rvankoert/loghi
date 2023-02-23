#!/bin/bash

GPU=0
# SRC should be the directory containing the images.
SRC=/data/filotas/bladiebla/
#should match up training height/width
BASELINEP2PALAHEIGHTWIDTH="1024 1024"

# this should point to the dir containing your models
MODELDIR=/src/models/
PREVMODEL=$MODELDIR/baseline_detection-5_checkpoint.pth


tmpdir=$(mktemp -d)
mkdir -p $SRC/page

docker run --gpus all --rm -m 32000m -ti -v $MODELDIR:$MODELDIR -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
docker.p2pala python3 /src/P2PaLA/P2PaLA.py --img_size $BASELINEP2PALAHEIGHTWIDTH  --out_mode L --line_alg external   \
--prev_model $PREVMODEL --work_dir $tmpdir --no-do_train --do_prod --no-do_val --prod_data $SRC --gpu $GPU --num_workers 0

cp -r $tmpdir/results/prod/page $SRC/
docker run --rm -v $SRC/:$SRC/ dockeranalyzerwebservice_analyzerwebservice /src/agenttesseract/target/appassembler/bin/MinionExtractBaselines $SRC/page/ \
$SRC/page/ \
$SRC/page/
