#!/bin/bash

# set to 1 if you want to enable, 0 otherwise, select just one
BASELINEP2PALA=1
BASELINELOGHI=0

#single page
BASELINEP2PALAHEIGHTWIDTH="1536 1024"
#double page fast
BASELINEP2PALAHEIGHTWIDTH="1024 1536"
BASELINEP2PALAHEIGHTWIDTH="2048 1536"
#double page good quality
# BASELINEP2PALAHEIGHTWIDTH="1536 2048"

#set to 1 to enable automatic detection of height/width
BASELINEP2PALAAUTO=1

# set to 1 if you want to enable, 0 otherwise, select just one
HTRLOGHI=1
HTRPYLAIA=0

LINEDETECTIONLOGHIMODEL=model_globalise
# specialized for republic print
LINEDETECTIONLOGHIMODEL=model-republicrandomprint-val-0.03344
# first try on rotated model
LINEDETECTIONLOGHIMODEL=model-rotated-val-0.0XXXX
# current WIP
#LINEDETECTION_LOGHI_MODEL=model-current

HTRLOGHIMODEL=model-new7-republicprint-height48-cer-0.0009
#height 64, mixed model, but still training....
HTRLOGHIMODEL=model-latest
#height 64
HTRLOGHIMODEL=model-new8-ijsberg-valcer-0.045
#height 64
HTRLOGHIMODEL=model-new8-ijsberg-valcer-0.0415
# faily high quality generic 18th century model
HTRLOGHIMODEL=model-new8-ijsberg_republicrandom_prizepapers_64_val_loss_5.6246

HTRLOGHIMODEL=model-current
HTRLOGHIMODEL=model-new-10-ijsberg-cer-0.0519
HTRLOGHIMODEL=model-new10-ijsberg-cer-0.0488
HTRLOGHIMODEL=model-new10-ijsberg-cer-0.0476
HTRLOGHIMODEL=model-new10-ijsberg-cer-0.0488
# HTRLOGHIMODEL=model-new10-ijsberg-cer-0.0443
HTRLOGHIMODEL=/src/loghi-htr-models/model-new10-ijsberg-cer-0.0373
HTRLOGHIMODEL=/src/loghi-htr-models/model-new10-ijsberg_republicrandom_prizepapers_globalise_val_cer_ijsberg_globalise_0.0329
HTRLOGHIMODEL=/home/rutger/src/loghi-htr-models/new14_generic-2022-12-20-globalise_related-finetune_globalise
HTRLOGHIMODEL=/home/rutger/src/loghi-htr-models/model10-generic-2023-01-02
# HTRLOGHIMODEL=/tmp/tmp.eeJOqXEgFX/output/checkpoints/encoder12-saved-model-18-29.1521
#HTRLOGHIMODEL=model-new10-ijsberg-cer-0.03805
#HTRLOGHIMODEL=model-new10-ijsberg-cer-0.0879
#HTRLOGHIMODEL=model-new12-generic
#HTRLOGHIMODEL=/src/loghi-htr-models/model-new12-generic_synthetic
#HTRLOGHIMODEL=/src/loghi-htr-models/model12-all-withouth_synthetic_valcer_0.0477

# set this to 1 for recalculating reading order, line clustering and cleaning.
RECALCULATEREADINGORDER=0
# if the edge of baseline is closer than x pixels...
RECALCULATEREADINGORDERBORDERMARGIN=50
# clean if 1
RECALCULATEREADINGORDERCLEANBORDERS=0
# how many threads to use
RECALCULATEREADINGORDERTHREADS=4

#detect language of pagexml, set to 1 to enable, disable otherwise
DETECTLANGUAGE=1
#interpolate word locations
SPLITWORDS=1

GPU=0

DOCKERGPUPARAMS=""
if [[ $GPU -gt -1 ]] 
then
        DOCKERGPUPARAMS="--gpus all"
        echo "using GPU"
fi

# DO NO EDIT BELOW THIS LINE
if [ -z $1 ]; then echo "please provide path to images to be HTR-ed" && exit 1; fi;
tmpdir=/media/rutger/HDI0001/tmp/tmp.prizepapers/
tmpdir=/tmp/tmp.n9vBN73l2e
tmpdir=/tmp/tmp.limited; mkdir -p $tmpdir
tmpdir=$(mktemp -d)
echo $tmpdir

#SRC=/media/rutger/DIFOR1/data/1.05.14/83/
SRC=/media/rutger/DIFOR1/wic-test/
SRC=/media/rutger/DIFOR1/data/1.04.02/7536-2/
SRC=/data/prizepapersall/
SRC=/media/rutger/HDI0001/scratch/7536-2/
SRC=/scratch/limited/
SRC=$1

mkdir $tmpdir/imagesnippets/
mkdir $tmpdir/linedetection
mkdir $tmpdir/output


find $SRC -name '*.done' -exec rm -f "{}" \;

#baseline detection
#option1: P2PaLA
if [[ $BASELINEP2PALA -eq 1 ]]
then
        if [[ $BASELINEP2PALAAUTO -eq 1 ]]
        then
                echo "automatic detection p2pala height/width"
                by=256
                div=3
                mkdir $tmpdir/p2palainput
                echo "starting P2PaLA baseline detection"
                find $SRC -maxdepth 1 -name '*.jpg' > $tmpdir/linedetectionlist.txt
                find $SRC -maxdepth 1 -name '*.jpeg' >> $tmpdir/linedetectionlist.txt
                find $SRC -maxdepth 1 -name '*.JPG' >> $tmpdir/linedetectionlist.txt
                find $SRC -maxdepth 1 -name '*.JPEG' >> $tmpdir/linedetectionlist.txt
                find $SRC -maxdepth 1 -name '*.png' >> $tmpdir/linedetectionlist.txt
                for file in $(cat $tmpdir/linedetectionlist.txt) ; do
                        width=$(identify -format '%w' "$file")
                        height=$(identify -format '%h' "$file")
                        # echo "$width $height"
                        width=$(((($width+$by-1)/($by * $div)) * $by))
                        height=$(((($height+$by-1)/($by * $div)) * $by))
                        echo $file >> $tmpdir/p2palainput/$width-$height.txt
                done;
                for file in $(ls $tmpdir/p2palainput/*.txt) ; do
                        basename=$(basename -s .txt $file)
                        width=$(echo $basename|cut -d '-' -f 1)
                        height=$(echo  $basename|cut -d '-' -f 2)
                        echo $height
                        #let p2pala run on cpu (gpu -1), otherwise it will run out of memory with larger images
			echo "docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m -ti -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
                                docker.p2pala python3 /src/P2PaLA/P2PaLA.py --img_size $height $width  --out_mode L --line_alg external   \
                                --prev_model /src/models/baseline_detection-5_checkpoint.pth \
                                --work_dir $tmpdir \
                                --no-do_train \
                                --do_prod \
                                --no-do_val \
                                --prod_data $SRC \
                                --gpu $GPU \
                                --num_workers 0 \
                                --batch_size 1 \
                                --prod_img_list $file"

                        docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m -ti -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
                                docker.p2pala python3 /src/P2PaLA/P2PaLA.py --img_size $height $width  --out_mode L --line_alg external   \
                                --prev_model /src/models/baseline_detection-5_checkpoint.pth \
                                --work_dir $tmpdir \
                                --no-do_train \
                                --do_prod \
                                --no-do_val \
                                --prod_data $SRC \
                                --gpu $GPU \
                                --num_workers 0 \
                                --batch_size 1 \
                                --prod_img_list $file
                done
                echo $tmpdir
                # exit
        else
		echo "docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m -ti -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
                docker.p2pala python3 /src/P2PaLA/P2PaLA.py --img_size $BASELINEP2PALAHEIGHTWIDTH  --out_mode L --line_alg external   \
                        --prev_model /src/models/baseline_detection-5_checkpoint.pth --work_dir $tmpdir --no-do_train --do_prod --no-do_val --prod_data $SRC --gpu -1 --num_workers 0"

                # docker run --rm -m 32000m --gpus all -ti -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
                # docker.p2pala_new CUDA_VISIBLE_DEVICES=$GPU python3 /src/P2PaLA/P2PaLA.py --img_size 1536 1536 --out_mode L --line_alg external   \
                #         --prev_model /checkpoints/baseline_detection-5_checkpoint.pth --work_dir $tmpdir --no-do_train --do_prod --no-do_val --prod_data $SRC --gpu $GPU --num_workers 0
                #let p2pala run on cpu (gpu -1), otherwise it will run out of memory with larger images
                docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m -ti -v $SRC:$SRC -v /scratch/p2pala/:/checkpoints/   -v $tmpdir:$tmpdir  \
                docker.p2pala python3 /src/P2PaLA/P2PaLA.py --img_size $BASELINEP2PALAHEIGHTWIDTH  --out_mode L --line_alg external   \
                        --prev_model /src/models/baseline_detection-5_checkpoint.pth --work_dir $tmpdir --no-do_train --do_prod --no-do_val --prod_data $SRC --gpu -1 --num_workers 0
        fi
        cp -r $tmpdir/results/prod/page $SRC/
# invert image for classic P2PaLA
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v /tmp/workdir_p2pala:/tmp/workdir_p2pala docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionExtractBaselines \
                -input_path_png $SRC/page/ \
                -input_path_page $SRC/page/ \
                -output_path_page $SRC/page/ \
		-invert_image \
		-p2palaconfig /tmp/workdir_p2pala/config.json
fi
#option 2: linedetection
if [[ $BASELINELOGHI -eq 1 ]]
then
        echo "starting Loghi baselinedetection"
        find $SRC -maxdepth 1 -name '*.jpg' > $tmpdir/linedetectionlist.txt
        find $SRC -maxdepth 1 -name '*.jpeg' >> $tmpdir/linedetectionlist.txt
        find $SRC -maxdepth 1 -name '*.JPG' >> $tmpdir/linedetectionlist.txt
        find $SRC -maxdepth 1 -name '*.JPEG' >> $tmpdir/linedetectionlist.txt
        find $SRC -maxdepth 1 -name '*.png' >> $tmpdir/linedetectionlist.txt
        docker run $DOCKERGPUPARAMS -ti -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.linedetection python3.8 /src/main.py --gpu 0 --do_inference --inference_list $tmpdir/linedetectionlist.txt --existing_model /src/$LINEDETECTIONLOGHIMODEL --output $tmpdir/linedetection/ --compression_level 1 --channels 1
        docker run -ti -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionExtractBaselinesStartEndNew3 \
                -input_path_png $tmpdir/linedetection/ \
                -output_path_pagexml $SRC/page/
fi

#option 3: P2PaLA+start+end
# to be implemented


# tmpdir=/tmp/tmp.Ld4ZFa0aa1
# #HTR option 1 LoghiHTR
if [[ $HTRLOGHI -eq 1 ]]
then

        echo "starting Loghi HTR"
        # #pylaia takes 3 channels, rutgerhtr 4channels png or 3 with new models
       docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm \
       -v $SRC/:$SRC/ \
       -v $tmpdir:$tmpdir \
       docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew \
       -input_path $SRC \
       -outputbase $tmpdir/imagesnippets/ \
       -output_type png \
       -channels 4 \
       -threads 4
       find $tmpdir/imagesnippets/ -type f -name '*.png' > $tmpdir/lines.txt

	LOGHIDIR="$(dirname "${HTRLOGHIMODEL}")"
        # CUDA_VISIBLE_DEVICES=-1 python3 ~/src/htr/src/main.py --do_inference --channels 4 --height $HTR_LOGHI_MODEL_HEIGHT --existing_model ~/src/htr/$HTR_LOGHI_MODEL  --batch_size 32 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist ~/src/htr/$HTR_LOGHI_MODEL.charlist --gpu $GPU
#        docker run $DOCKERGPUPARAMS --rm -m 32000m --shm-size 10240m -ti -v $tmpdir:$tmpdir docker.htr python3 /src/src/main.py --do_inference --channels 4 --height $HTRLOGHIMODELHEIGHT --existing_model /src/loghi-htr-models/$HTRLOGHIMODEL  --batch_size 10 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist /src/loghi-htr-models/$HTRLOGHIMODEL.charlist --gpu $GPU --output $tmpdir/output/ --config_file_output $tmpdir/output/config.txt --beam_width 10
        docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $LOGHIDIR:$LOGHIDIR docker.htr python3 /src/src/main.py \
        --do_inference \
        --existing_model $HTRLOGHIMODEL  \
        --batch_size 64 \
        --use_mask \
        --inference_list $tmpdir/lines.txt \
        --results_file $tmpdir/results.txt \
        --charlist $HTRLOGHIMODEL.charlist \
        --gpu $GPU \
        --output $tmpdir/output/ \
        --config_file_output $tmpdir/output/config.json \
        --beam_width 1 \
	--greedy
        # docker run --rm -m 32000m --gpus all --shm-size 10240m -ti -v $tmpdir:$tmpdir docker.htr python3 /src/src/main.py --do_inference --channels 4 --height $HTR_LOGHI_MODEL_HEIGHT --existing_model /src/$HTR_LOGHI_MODEL  --batch_size 32 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist /src/$HTR_LOGHI_MODEL.charlist --gpu $GPU
        # docker run --rm -m 32000m --shm-size 10240m --gpus all -ti -v $tmpdir:$tmpdir docker.htr python3 /src/src/main.py --do_inference --channels 4 --height $HTR_LOGHI_MODEL_HEIGHT --existing_model /src/$HTR_LOGHI_MODEL  --batch_size 32 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist /src/$HTR_LOGHI_MODEL.charlist --gpu $GPU --beam_width 1
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionLoghiHTRMergePageXML \
                -input_path $SRC/page \
                -results_file $tmpdir/results.txt \
                -config_file $tmpdir/output/config.json
fi

#HTR option2 pylaia
if [[ $HTRPYLAIA -eq 1 ]]
then
        #pylaia takes 3 channels, rutgerhtr 4channels png
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew \
		-input_path $SRC \
		-outputbase $tmpdir/imagesnippets/ \
		-output_type jpg \
		-channels 3 \
		-rescaleheight 128 \
		-threads 4
        >$tmpdir/results.txt

        for dir in $(find $tmpdir/imagesnippets/ -type d) ; do
                ls $dir/*.jpg > $dir.txt && \
                docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m --shm-size 10240m -ti -v $tmpdir:$tmpdir docker.pylaia \
                        bash -c "pylaia-htr-decode-ctc syms.txt $dir.txt --common.model_filename model_h128 --config=decode_config.yaml --img_dirs=[$dir] >> $tmpdir/results.txt"
        done;
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionPyLaiaMergePageXML \
                $SRC/page $tmpdir/results.txt
fi

if [[ $RECALCULATEREADINGORDER -eq 1 ]]
then
        echo "recalculating reading order"
        if [[ $RECALCULATEREADINGORDERCLEANBORDERS -eq 1 ]]
        then
                echo "and cleaning"
                docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionRecalculateReadingOrderNew \
                        -input_dir $SRC/page/ \
			-border_margin $RECALCULATEREADINGORDERBORDERMARGIN \
			-clean_borders \
			-threads $RECALCULATEREADINGORDERTHREADS
        else
                docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionRecalculateReadingOrderNew \
                        -input_dir $SRC/page/ \
			-border_margin $RECALCULATEREADINGORDERBORDERMARGIN \
			-threads $RECALCULATEREADINGORDERTHREADS
        fi
fi
if [[ $DETECTLANGUAGE -eq 1 ]]
then
        echo "detecting language..."
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionDetectLanguageOfPageXml \
                -page $SRC/page/
fi


if [[ $SPLITWORDS -eq 1 ]]
then
        echo "MinionSplitPageXMLTextLineIntoWords..."
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionSplitPageXMLTextLineIntoWords \
                -input_path $SRC/page/
fi

# cleanup results
# rm -rf $tmpdir

