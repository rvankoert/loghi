#

TRAIN=/media/rutger/HDI0002/tmp/data_train/
VAL=/media/rutger/HDI0002/tmp/data_val/
GPU=-1
IMGSIZE="1024 1536"
BATCHSIZE=1
OUTMODE=R
cnn_ngf=8
epochs=1
WORKDIR=/tmp/workdir_p2pala/
P2PALA=docker.p2pala

mkdir -p $WORKDIR

echo docker run --gpus all -m 20000m --shm-size 10240m \
-v /media/rutger/DIFOR1/:/media/rutger/DIFOR1/ \
-v $TRAIN:$TRAIN \
-v $VAL:$VAL \
-v $WORKDIR:$WORKDIR \
--rm -ti $P2PALA python3 /src/P2PaLA/P2PaLA.py \
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
--use_global_log $WORKDIR/log/


docker run --gpus all -m 20000m --shm-size 10240m \
-v /media/rutger/DIFOR1/:/media/rutger/DIFOR1/ \
-v $TRAIN:$TRAIN \
-v $VAL:$VAL \
-v $WORKDIR:$WORKDIR \
--rm -ti $P2PALA python3 /src/P2PaLA/P2PaLA.py \
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
--use_global_log $WORKDIR/log/
