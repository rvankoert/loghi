#!/bin/bash
# set to 1 if you want to enable, 0 otherwise, select just one
HTRLOGHI=1

HTRLOGHIMODELHEIGHT=64

HTRLOGHIMODEL=/src/loghi-htr-models/model-new12-generic_synthetic
# HTRLOGHIMODEL=/tmp/tmp.eeJOqXEgFX/output/checkpoints/encoder12-saved-model-18-29.1521
# maar!!!! zorg er voor dat alle karakters in de nieuwe set ook voorkomen in de bestaande.
#--existing_model $HTRLOGHIMODEL

USEBASEMODEL=0
#number of input channels to use
channels=1

GPU=0

#UPDATE THESE PATHS TO YOUR OWN FILES
listdir=/scratch/randomprint2_lines
trainlist=$listdir/training_all_train.txt
validationlist=$listdir/training_all_val.txt
#directory that contains the actual line strips
datadir=/scratch/republicprint

charlist=/data/htr_train_notdeeds/output_charlist.charlist

epochs=20
height=$HTRLOGHIMODELHEIGHT
multiply=1
#minimum 2, maximum 5
rnn_layers=5
#minimum ??? maximum 1024?, bij kleine datasets wat lager.
rnn_units=256
batch_size=8
model_name=myfirstmodel
# tussen de 0.001 en 0.00001
learning_rate=0.0001
DECAYSTEPS=-1

# DO NO EDIT BELOW THIS LINE
tmpdir=$(mktemp -d)
echo $tmpdir
mkdir $tmpdir/output

if [[ $USEBASEMODEL -eq 1 ]]
then
        BASEMODEL=" --existing_model "$HTRLOGHIMODEL
        echo $BASEMODEL
fi

# #HTR option 1 LoghiHTR
if [[ $HTRLOGHI -eq 1 ]]
then
        echo "starting Loghi HTR"
        echo docker run --gpus all --rm  -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $listdir:$listdir -v $datadir:$datadir loghi/docker.htr python3 /src/src/main.py --do_train --train_list $trainlist --validation_list $validationlist --learning_rate $learning_rate --channels 4 --batch_size $batch_size --epochs $epochs --do_validate --gpu $GPU --height $height --use_mask --seed 1  --beam_width 10 --model new10 --rnn_layers $rnn_layers --rnn_units $rnn_units --use_gru --decay_steps 5000 --batch_normalization --multiply $multiply --output $listdir --model_name $model_name --output_charlist $tmpdir/output_charlist.charlist --output $tmpdir/output

docker run --gpus all --rm  -u $(id -u ${USER}):$(id -g ${USER}) -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $listdir:$listdir -v $datadir:$datadir loghi/docker.htr python3 /src/src/main.py --do_train --train_list $trainlist --validation_list $validationlist --learning_rate $learning_rate --channels 4 --batch_size $batch_size --epochs $epochs --do_validate --gpu $GPU --height $height --use_mask --seed 1  --beam_width 10 --model new10 --rnn_layers $rnn_layers --rnn_units $rnn_units --use_gru --decay_steps 5000 --batch_normalization --multiply $multiply --output $listdir --model_name $model_name --output_charlist $tmpdir/output_charlist.charlist --output $tmpdir/output


# --replace_recurrent_layer \
# --use_rnn_dropout \
# --batch_normalization \
# --dropout_rnn 0.5 \
#--replace_final \

fi

echo "you can find the results here: "
echo $tmpdir

# cleanup results
# rm -rf $tmpdir
