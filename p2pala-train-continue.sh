#!/bin/bash

# p2pala_new ignores img_size, but instead resizes on the fly. This is experimental
# p2pala is the old version and requires img_size, but should work better when training inferencing on similar size pages.
# --val_out_size_list is only needed for p2pala_new

P2PALA=docker.p2pala

TRAIN=/media/rutger/DIFOR2/BASELINE_GT_NEW/train/
VAL=/media/rutger/DIFOR2/BASELINE_GT_NEW/val/
GPU=0
#must match existing workdir of previous run
WORKDIR=/tmp/workdir_p2pala/
IMGSIZE="1024 1024"
BATCHSIZE=1
OUTMODE=L
cnn_ngf=64
epochs=100

mkdir -p $WORKDIR

# bug in existing p2pala: you need to explicitly leave out val_img_list+label_list

docker run --gpus all -m 20000m --shm-size 10240m \
-v /media/rutger/DIFOR1/:/media/rutger/DIFOR1/ \
-v $TRAIN:$TRAIN \
-v $VAL:$VAL \
-v $WORKDIR:$WORKDIR \
--rm -ti $P2PALA python3 /src/P2PaLA/P2PaLA.py \
--work_dir $WORKDIR \
--img_size $IMGSIZE \
--tr_data $TRAIN \
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
--tr_img_list $WORKDIR/data/train/img.lst \
--tr_label_list $WORKDIR/data/train/label.lst \
--prev_model $WORKDIR/checkpoints/best_undervalNLLcriterion.pth \
--cont_train \
--line_width 8

#--val_img_list $WORKDIR/data/val/img.lst \
#--val_label_list $WORKDIR/data/val/label.lst \


#--val_out_size_list /tmp/workdir/data/val/out_size.lst \
#--tr_out_size_list /tmp/workdir/data/train/out_size.lst \
