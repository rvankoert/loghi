#!/bin/bash

TRAIN=/media/rutger/DIFOR21/BASELINE_GT_NEW/train_small/
VAL=/media/rutger/DIFOR21/BASELINE_GT_NEW/val_small/
# set to -1 for cpu, 0 for GPU
GPU=0
WORKDIR=/tmp/workdir_p2pala/
IMGSIZE="1024 1024"
BATCHSIZE=1
OUTMODE=L
P2PALA=docker.p2pala
epochs=1
cnn_ngf=64

mkdir -p $WORKDIR

docker run --gpus all -m 20000m --shm-size 10240m \
-v /media/rutger/DIFOR1/:/media/rutger/DIFOR1/ \
-v $TRAIN:$TRAIN \
-v $VAL:$VAL \
-v $WORKDIR:$WORKDIR \
--rm -ti $P2PALA python3.8 /src/P2PaLA/P2PaLA.py \
--work_dir $WORKDIR \
--img_size $IMGSIZE \
--tr_data $TRAIN \
--do_train \
--do_val \
--val_data $VAL \
--batch_size $BATCHSIZE \
--num_workers 8 \
--gpu $GPU \
--regions marginalia page-number resolution attendance date index \
--merge_regions resolution:Resumption,resumption,insertion,Insertion \
--input_channels 3 \
--out_mode $OUTMODE \
--net_out_type C \
--cnn_ngf $cnn_ngf \
--epochs $epochs \
--line_width 8
