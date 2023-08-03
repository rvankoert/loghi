
# set to 1 if you want to enable, 0 otherwise, select just one
HTRLOGHI=1
HTRPYLAIA=0

# LINEDETECTION_LOGHI_MODEL=model_globalise
# LINEDETECTION_LOGHI_MODEL=model-republicrandomprint-val-0.03344
# LINEDETECTION_LOGHI_MODEL=model-rotated-val-0.0XXXX

HTRLOGHIMODELHEIGHT=48
HTRLOGHIMODELHEIGHT=64

#height 48
HTRLOGHIMODEL=model-new7-republicprint-height48-cer-0.0009
#height 64, mixed model, but still training....
HTRLOGHIMODEL=model-latest
#height 64
HTRLOGHIMODEL=model-new8-ijsberg-valcer-0.045
#height 64
HTRLOGHIMODEL=model-new8-ijsberg-valcer-0.0415

HTRLOGHIMODEL=model-new8-ijsberg_republicrandom_prizepapers_64_val_loss_5.6246
HTRLOGHIMODEL=/src/loghi-htr-models/model-new10-ijsberg-cer-0.0373
HTRLOGHIMODEL=/src/loghi-htr-models/model-new12-generic_synthetic
# HTRLOGHIMODEL=/tmp/tmp.eeJOqXEgFX/output/checkpoints/encoder12-saved-model-18-29.1521
# maar!!!! zorg er voor dat alle karakters in de nieuwe set ook voorkomen in de bestaande.
#--existing_model $HTRLOGHIMODEL

USEBASEMODEL=0
#number of input channels to use
channels=1

GPU=0
listdir=/data/htr_train_notdeeds
trainlist=/data/htr_train_notdeeds/training_all_train.txt
validationlist=/data/htr_train_notdeeds/training_all_train.txt
charlist=/data/htr_train_notdeeds/output_charlist.charlist

epochs=20
height=$HTRLOGHIMODELHEIGHT
multiply=2
#minimum 2, maximum 5
rnn_layers=3
#minimum ??? maximum 1024?, bij kleine datasets wat lager.
rnn_units=1024
batch_size=2
model_name=myfirstmodel
# tussen de 0.001 en 0.00001
learning_rate=0.0003
DECAYSTEPS=3000

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
        # #pylaia takes 3 channels, rutgerhtr 4channels png or 3 with new models
        echo docker run --gpus all --rm -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $listdir:$listdir docker.htr python3 /src/src/main.py --do_train --train_list $trainlist --validation_list $validationlist --learning_rate $learning_rate --channels 4 --batch_size $batch_size --epochs $epochs --do_validate --gpu $GPU --height $height --use_mask --seed 1  --beam_width 10 --model new10 --rnn_layers $rnn_layers --rnn_units $rnn_units --use_gru --decay_steps 5000 --batch_normalization --multiply $multiply --output $listdir --model_name $model_name --output_charlist $tmpdir/output_charlist.charlist --output $tmpdir/output
	#docker run --gpus all --rm -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $listdir:$listdir docker.htr python3 /src/src/main.py --do_train --train_list $trainlist \
#$BASEMODEL --validation_list $validationlist \
#--learning_rate $learning_rate \
#--channels $channels \
#--batch_size $batch_size \
#--epochs $epochs \
#--do_validate \
#--gpu $GPU \
#--height $height \
#--use_mask \
#--seed 1  \
#--beam_width 10 \
#--model new10 \
#--decay_steps $DECAYSTEPS \
#--multiply $multiply \
#--output $listdir \
#--model_name $model_name \
#--output $tmpdir/output \
#--random_width \
#--replace_final \
#--use_gru \
#--augment \
#--rnn_layers $rnn_layers \
#--rnn_units $rnn_units \
#--elastic_transform \
#--check_missing_files

docker run --gpus all --rm -m 32000m --shm-size 10240m -ti -v /tmp:/tmp -v $tmpdir:$tmpdir -v $listdir:$listdir docker.htr python3 /src/loghi-htr/src/main.py --do_train --train_list $trainlist --validation_list $validationlist --learning_rate $learning_rate --channels 4 --batch_size $batch_size --epochs $epochs --do_validate --gpu $GPU --height $height --use_mask --seed 1  --beam_width 10 --model new10 --rnn_layers $rnn_layers --rnn_units $rnn_units --use_gru --decay_steps 5000 --batch_normalization --multiply $multiply --output $listdir --model_name $model_name --output_charlist $tmpdir/output_charlist.charlist --output $tmpdir/output


# --replace_recurrent_layer \
# --use_rnn_dropout \
# --batch_normalization \
# --dropout_rnn 0.5 \
#--replace_final \

fi

# #HTR option2 pylaia
# if [[ $HTR_PYLAIA -eq 1 ]]
# then
#         #pylaia takes 3 channels, rutgerhtr 4channels png
#         docker run --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir dockeranalyzerwebservice_analyzerwebservice /src/agenttesseract/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path $SRC -outputbase $tmpdir/imagesnippets/ -output_type jpg -channels 3 -rescaleheight 128 -threads 4
#         >$tmpdir/results.txt

#         for dir in $(find $tmpdir/imagesnippets/ -type d) ; do
#                 ls $dir/*.jpg > $dir.txt && \
#                 docker run --rm -m 32000m --shm-size 10240m -ti -v $tmpdir:$tmpdir docker.pylaia \
#                         bash -c "pylaia-htr-decode-ctc syms.txt $dir.txt --common.model_filename model_h128 --config=decode_config.yaml --img_dirs=[$dir] >> $tmpdir/results.txt"
#         done;
#         docker run --rm -v $SRC/:$SRC/ -v $tmpdir:$tmpdir dockeranalyzerwebservice_analyzerwebservice /src/agenttesseract/target/appassembler/bin/MinionPyLaiaMergePageXML $SRC/page $tmpdir/results.txt
# fi

echo "you can find the results here: "
echo $tmpdir

# cleanup results
# rm -rf $tmpdir
