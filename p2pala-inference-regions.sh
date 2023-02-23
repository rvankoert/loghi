#

PROD=/media/rutger/HDI0002/tmp/data_val/
GPU=-1
WORKDIR=/tmp/workdir_p2pala
RESULTSDIR=$WORKDIR/results/prod/
IMGSIZE="1024 1536"
BATCHSIZE=1
cnn_ngf=8
OUTMODE=R
MODEL=$WORKDIR/checkpoints/best_undervalNLLcriterion.pth
#MODEL=/tmp/workdir_p2pala/checkpoints/best_undervalNLLcriterion.pth

mkdir -p $WORKDIR

echo docker run --gpus all -m 20000m --shm-size 10240m \
-v $PROD:$PROD \
-v $WORKDIR:$WORKDIR \
--rm -ti docker.p2pala python3 /src/P2PaLA/P2PaLA.py \
--work_dir $WORKDIR \
--img_size $IMGSIZE \
--no-do_val \
--no-do_train \
--no-do_test \
--do_prod \
--prod_data $PROD \
--batch_size $BATCHSIZE \
--regions marginalia page-number resolution attendance date index \
--merge_regions resolution:Resumption,resumption,insertion,Insertion \
--num_workers 8 \
--gpu $GPU \
--input_channels 3 \
--out_mode $OUTMODE \
--cnn_ngf $cnn_ngf \
--prev_model $MODEL \
--use_global_log $WORKDIR/log/


docker run --gpus all -m 20000m --shm-size 10240m \
-v $PROD:$PROD \
-v $WORKDIR:$WORKDIR \
--rm -ti docker.p2pala python3 /src/P2PaLA/P2PaLA.py \
--work_dir $WORKDIR \
--img_size $IMGSIZE \
--no-do_val \
--no-do_train \
--no-do_test \
--do_prod \
--prod_data $PROD \
--batch_size $BATCHSIZE \
--regions marginalia page-number resolution attendance date index \
--merge_regions resolution:Resumption,resumption,insertion,Insertion \
--num_workers 8 \
--gpu $GPU \
--input_channels 3 \
--out_mode $OUTMODE \
--cnn_ngf $cnn_ngf \
--prev_model $MODEL \
--use_global_log $WORKDIR/log/


#echo docker run --rm -v $PROD/:$PROD/ dockeranalyzerwebservice_analyzerwebservice /src/agenttesseract/target/appassembler/bin/MinionExtractBaselines $PROD/page/ \
#                $PROD/page/ \
#                $PROD/page/
#
#docker run --rm -v $WORKDIR/:$WORKDIR/ dockeranalyzerwebservice_analyzerwebservice /src/agenttesseract/target/appassembler/bin/MinionExtractBaselines $RESULTSDIR/page/ \
#                $RESULTSDIR/page/ \
#                $RESULTSDIR/page/

