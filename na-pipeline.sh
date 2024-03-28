#!/bin/bash
VERSION=1.3.13
set -e

# Stop on error, if set to 1 will exit program if any of the docker commands fail
STOPONERROR=1

# set to 1 if you want to enable, 0 otherwise, select just one
BASELINELAYPA=1
REGIONLAYPA=0

#
#LAYPAMODEL=/home/rutger/src/laypa-models/general/baseline/config.yaml
#LAYPAMODELWEIGHTS=/home/rutger/src/laypa-models/general/baseline/model_best_mIoU.pth

LAYPABASELINEMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPABASELINEMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE

# Not required if REGIONLAYPA is 0
LAYPAREGIONMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPAREGIONMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE

# set to 1 if you want to enable, 0 otherwise, select just one
HTRLOGHI=1

#HTRLOGHIMODEL=/home/rutger/src/loghi-htr-models/republic-2023-01-02-base-generic_new14-2022-12-20-valcer-0.0062
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE

# set this to 1 for recalculating reading order, line clustering and cleaning.
# WARNING this will remove regions found by Laypa
RECALCULATEREADINGORDER=1
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
#BEAMWIDTH: higher makes results slightly better at the expense of lot of computation time. In general don't set higher than 10
BEAMWIDTH=1
#used gpu ids, set to "-1" to use CPU, "0" for first, "1" for second, etc
GPU=0

DOCKERLOGHITOOLING=loghi/docker.loghi-tooling:$VERSION
DOCKERLAYPA=loghi/docker.laypa:$VERSION
DOCKERLOGHIHTR=loghi/docker.htr:$VERSION
USE2013NAMESPACE=" -use_2013_namespace "

# DO NO EDIT BELOW THIS LINE
if [ -z $1 ]; then echo "please provide path to images to be HTR-ed" && exit 1; fi;
tmpdir=$(mktemp -d)
echo $tmpdir

DOCKERGPUPARAMS=""
if [[ $GPU -gt -1 ]]; then
        DOCKERGPUPARAMS="--gpus device=${GPU}"
        echo "using GPU ${GPU}"
fi

SRC=`realpath $1`

mkdir $tmpdir/imagesnippets/
mkdir $tmpdir/linedetection
mkdir $tmpdir/output


find $SRC -name '*.done' -exec rm -f "{}" \;


if [[ $BASELINELAYPA -eq 1 ]]
then
        echo "starting Laypa baseline detection"

        input_dir=$SRC
        output_dir=$SRC
        LAYPADIR="$(dirname "${LAYPABASELINEMODEL}")"

        if [[ ! -d $input_dir ]]; then
                echo "Specified input dir (${input_dir}) does not exist, stopping program"
                exit 1
        fi

        if [[ ! -d $output_dir ]]; then
                echo "Could not find output dir (${output_dir}), creating one at specified location"
                mkdir -p $output_dir
        fi

	echo docker run $DOCKERGPUPARAMS --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -v $LAYPADIR:$LAYPADIR -v $input_dir:$input_dir -v $output_dir:$output_dir $DOCKERLAYPA \
        python run.py \
        -c $LAYPABASELINEMODEL \
        -i $input_dir \
        -o $output_dir \
        --opts MODEL.WEIGHTS "" TEST.WEIGHTS $LAYPABASELINEMODELWEIGHTS | tee -a $tmpdir/log.txt

        docker run $DOCKERGPUPARAMS --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -v $LAYPADIR:$LAYPADIR -v $input_dir:$input_dir -v $output_dir:$output_dir $DOCKERLAYPA \
        python run.py \
        -c $LAYPABASELINEMODEL \
        -i $input_dir \
        -o $output_dir \
        --opts MODEL.WEIGHTS "" TEST.WEIGHTS $LAYPABASELINEMODELWEIGHTS | tee -a $tmpdir/log.txt

        # > /dev/null

        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "Laypa baseline has errored, stopping program"
                exit 1
        fi

        as_single_region="-as_single_region"

        if [[ $REGIONLAYPA -eq 1 ]]
        then
                echo "starting Laypa region detection"
                

                LAYPADIR="$(dirname "${LAYPAREGIONMODEL}")"

                echo docker run $DOCKERGPUPARAMS --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -v $LAYPADIR:$LAYPADIR -v $input_dir:$input_dir -v $output_dir:$output_dir $DOCKERLAYPA \
                python run.py \
                -c $LAYPAREGIONMODEL \
                -i $input_dir \
                -o $output_dir \
                --opts MODEL.WEIGHTS "" TEST.WEIGHTS $LAYPAREGIONMODELWEIGHTS | tee -a $tmpdir/log.txt

                docker run $DOCKERGPUPARAMS --rm -it -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -v $LAYPADIR:$LAYPADIR -v $input_dir:$input_dir -v $output_dir:$output_dir $DOCKERLAYPA \
                python run.py \
                -c $LAYPAREGIONMODEL \
                -i $input_dir \
                -o $output_dir \
                --opts MODEL.WEIGHTS "" TEST.WEIGHTS $LAYPAREGIONMODELWEIGHTS | tee -a $tmpdir/log.txt

                # > /dev/null

                if [[ $STOPONERROR && $? -ne 0 ]]; then
                        echo "Laypa region has errored, stopping program"
                        exit 1
                fi

                as_single_region=""
        fi

        docker run --rm -u $(id -u ${USER}):$(id -g ${USER}) -v $output_dir:$output_dir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionExtractBaselines \
        -input_path_png $output_dir/page/ \
        -input_path_page $output_dir/page/ \
        -output_path_page $output_dir/page/ \
        -recalculate_textline_contours_from_baselines \
        $as_single_region $USE2013NAMESPACE | tee -a $tmpdir/log.txt


        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "MinionExtractBaselines (Laypa) errored has errored, stopping program"
                exit 1
        fi
fi

# #HTR option 1 LoghiHTR
if [[ $HTRLOGHI -eq 1 ]]
then

        echo "starting Loghi HTR"
        # #pylaia takes 3 channels, rutgerhtr 4channels png or 3 with new models
       docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm \
       -v $SRC/:$SRC/ \
       -v $tmpdir:$tmpdir \
       $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew \
       -input_path $SRC \
       -outputbase $tmpdir/imagesnippets/ \
       -output_type png \
       -channels 4 \
       -threads 4 $USE2013NAMESPACE| tee -a $tmpdir/log.txt


        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "MinionCutFromImageBasedOnPageXMLNew has errored, stopping program"
                exit 1
        fi

       find $tmpdir/imagesnippets/ -type f -name '*.png' > $tmpdir/lines.txt

	LOGHIDIR="$(dirname "${HTRLOGHIMODEL}")"
        # CUDA_VISIBLE_DEVICES=-1 python3 ~/src/htr/src/main.py --do_inference --channels 4 --height $HTR_LOGHI_MODEL_HEIGHT --existing_model ~/src/htr/$HTR_LOGHI_MODEL  --batch_size 32 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist ~/src/htr/$HTR_LOGHI_MODEL.charlist --gpu $GPU
#        docker run $DOCKERGPUPARAMS --rm -m 32000m --shm-size 10240m -ti -v $tmpdir:$tmpdir docker.htr python3 /src/src/main.py --do_inference --channels 4 --height $HTRLOGHIMODELHEIGHT --existing_model /src/loghi-htr-models/$HTRLOGHIMODEL  --batch_size 10 --use_mask --inference_list $tmpdir/lines.txt --results_file $tmpdir/results.txt --charlist /src/loghi-htr-models/$HTRLOGHIMODEL.charlist --gpu $GPU --output $tmpdir/output/ --config_file_output $tmpdir/output/config.txt --beam_width 10
        docker run $DOCKERGPUPARAMS -u $(id -u ${USER}):$(id -g ${USER}) --rm -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $LOGHIDIR:$LOGHIDIR $DOCKERLOGHIHTR \
	bash -c "LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 python3 /src/loghi-htr/src/main.py \
        --do_inference \
        --existing_model $HTRLOGHIMODEL  \
        --batch_size 64 \
        --use_mask \
        --inference_list $tmpdir/lines.txt \
        --results_file $tmpdir/results.txt \
        --charlist $HTRLOGHIMODEL/charlist.txt \
        --gpu $GPU \
        --output $tmpdir/output/ \
        --config_file_output $tmpdir/output/config.json \
        --beam_width $BEAMWIDTH " | tee -a $tmpdir/log.txt

        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "Loghi-HTR has errored, stopping program"
                exit 1
        fi
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $LOGHIDIR:$LOGHIDIR -v $SRC/:$SRC/ -v $tmpdir:$tmpdir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionLoghiHTRMergePageXML \
                -input_path $SRC/page \
                -results_file $tmpdir/results.txt \
                -config_file $HTRLOGHIMODEL/config.json -htr_code_config_file $tmpdir/output/config.json $USE2013NAMESPACE | tee -a $tmpdir/log.txt


        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "MinionLoghiHTRMergePageXML has errored, stopping program"
                exit 1
        fi
fi

if [[ $RECALCULATEREADINGORDER -eq 1 ]]
then
        echo "recalculating reading order"
        if [[ $RECALCULATEREADINGORDERCLEANBORDERS -eq 1 ]]
        then
                echo "and cleaning"
                docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionRecalculateReadingOrderNew \
                        -input_dir $SRC/page/ \
			-border_margin $RECALCULATEREADINGORDERBORDERMARGIN \
			-clean_borders \
			-threads $RECALCULATEREADINGORDERTHREADS $USE2013NAMESPACE | tee -a $tmpdir/log.txt

                if [[ $STOPONERROR && $? -ne 0 ]]; then
                        echo "MinionRecalculateReadingOrderNew has errored, stopping program"
                        exit 1
                fi
        else
                docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionRecalculateReadingOrderNew \
                        -input_dir $SRC/page/ \
			-border_margin $RECALCULATEREADINGORDERBORDERMARGIN \
			-threads $RECALCULATEREADINGORDERTHREADS $USE2013NAMESPACE| tee -a $tmpdir/log.txt

                if [[ $STOPONERROR && $? -ne 0 ]]; then
                        echo "MinionRecalculateReadingOrderNew has errored, stopping program"
                        exit 1
                fi
        fi
fi
if [[ $DETECTLANGUAGE -eq 1 ]]
then
        echo "detecting language..."
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionDetectLanguageOfPageXml \
                -page $SRC/page/ $USE2013NAMESPACE | tee -a $tmpdir/log.txt


        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "MinionDetectLanguageOfPageXml has errored, stopping program"
                exit 1
        fi
fi


if [[ $SPLITWORDS -eq 1 ]]
then
        echo "MinionSplitPageXMLTextLineIntoWords..."
        docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir $DOCKERLOGHITOOLING /src/loghi-tooling/minions/target/appassembler/bin/MinionSplitPageXMLTextLineIntoWords \
                -input_path $SRC/page/ $USE2013NAMESPACE | tee -a $tmpdir/log.txt

        if [[ $STOPONERROR && $? -ne 0 ]]; then
                echo "MinionSplitPageXMLTextLineIntoWords has errored, stopping program"
                exit 1
        fi
fi

# cleanup results
rm -rf $tmpdir

