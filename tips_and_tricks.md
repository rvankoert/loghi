# Tips & Tricks for training Loghi
# THIS FILE IS IN NEED OF AN UPDATE AS IT STILL REFERENCES OLDER LOGHI-TOOLING.

## Training

### Get Training Data

First get some training and validation data. 
This needs to be of the format image+ PageXML.
Either by downloading:

https://zenodo.org/record/4159268\#.YlhnaHVBz0o

Or create some of your own using the Transkribus Expert Client, Tools from Prima Labs, or even type out the PageXML yourself.

Another option is generating synthetic data by using the "generate-images.sh" script which is available via the surfdrive. 
Please copy this script and edit the paths in the script so they point to the correct data.

### Training baseline detection

#### P2PaLA

Currently baseline detection is done by P2PaLA. 
The default P2PaLA settings of *p2pala-train.sh* (in surfdrive) have worked for a variety of documents.
Make sure you set the TRAIN and VAL parameters to paths with existing data for example the data downloaded in the paragraph *Get Training Data*. 
Make sure the WORKDIR points to an existing directory.

Besides changing the TRAIN and VAL parameters, you might want to experiment with the following parameters.

- IMG_SIZE: the larger the images the more precise the baselines can be determined. 
The larger will occupy more memory.

- BATCH_SIZE: the default value is 1, this wil make it possible to train P2PaLA on variety of systems. 
The training  will be faster with a larger batch size, but this will requirement more memory from  your GPU.

- epochs: the number of epochs should be more than 1. 100 is a common value.

- cnn_ngf: this is the number of filters of the convolutional layers of the neural network. 
The default value is 64. 
The higher the number the more fine grained the filters will become. 
The lower the number the more coarse the filters are. The finer the filters the longer the network needs to be trained. 
The higher number will not always reap the best results.

- OUTMODE gives P2PaLA the instruction to train on baselines (L) or textregions (TR)

More P2PaLA information can be found on:
https://github.com/rvankoert/P2PaLA/blob/master/docs/help.md and https://github.com/rvankoert/P2PaLA/blob/master/docs/USAGE.md

### Training HTR

#### Convert Data to format usable for Loghi Framework
```bash
docker run --rm -v \$SRC/:\$SRC/ -v \$tmpdir:\$tmpdir docker.loghi-tooling /src/loghi-tooling/minions//target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew -input_path \$SRC -outputbase \$tmpdir/imagesnippets/ -output_type png -channels 4 -threads 4
```

Replace \$SRC with the dir where images and page are. 
This means images in one dir and in that dir a folder named "page" containing the pagexml-files. 
The corresponding page needs to follow the convention IMAGEFILENAME.xml where IMAGEFILENAME.jpg is the imagefile. 
(This is Transkribus default)

Replace \$tmpdir with the path to the directory where you want the output-results.

Now we should have the text lines as separate image-files. A convenience script that makes life easier is provided:

create_train_data.sh

Just run it and follow the instructions.

The generated training data can be used for the Loghi Framework (and with some alterations for PyLaia, this is work to be done).


#### Create and train a neural network

In general you can use the default settings and only provide the training list and validation list.

When you have little data or don't care about training time and want the best results use:

--random_width: augments the data by stretching and squeezing the
input textline horizontally

--elastic_transform: augments the data by a random elastic transform

You do you need a bit more epochs, but it will be worth it. Especially
with little data.

Little data: use a lower batch_size:

--batch_size 2

Tons of data: use a higher batch_size:

--batch_size 24

If you run out of memory during training: lower the batch size or  decrease the size of your network by using less layers and units.

Or stick with something like 4 with a lower learning rate and more epochs to get a better result

In general: more epochs = better results. Only the validation scores are really interesting. 
The loss and CER on the training are not as relevant.

To improve results during inference or validation increase the beam_width:

--beam_width 10 (or higher)

This slows down the decoding process, but will improve the results in general.

The recurrent part of the network is where the magic happens and tiny parts are combined into a transcription. 
There are parameters for this part you can change.

The number of layers. I haven't tried more than 5 or less than 3. 
3 seems fine for most cases. 

--rnn_layers 3

The number of neural network units. Higher can mean better, but too much and the network overfits easily. 
Numbers tried with working results:
128, 256, 512, 1024

--rnn_units 256

To avoid overfitting you can use dropout in the rnn-layers. 
This means the network will learn the features more robustly at the expense of longer training time. 
This is a must when training on smaller datasets or if you want the best results.

--use_rnn_dropout

In general you want this turned on.

There are two rnn-types to use: LSTM or GRU. 
The default is LSTM and if you to use GRU use:

--use_gru

Advanced: To reuse an existing model without changing the recurrent layers you can use:

--freeze_recurrent_layers

Advanced: Make sure to unfreeze them later in fine-tune training using:

--thaw

Advanced:

--freeze_dense_layers

Advanced:

--freeze_conv_layers

Advanced: multiply training data. 
This just makes one epoch run on more of the same training data. 
You can use this with tiny datasets when you don't want the overhead of each validation run.

--multiply 1

To reuse an existing model you can use:

--existing_model MODEL_NAME_HERE

Make sure to add

--charlist MODEL_NAME_HERE.charlist

In the current version you yourself need to make sure to store the charlist as the correct filename. 
THIS IS NOT DONE AUTOMATICALLY YET.

####### Training

--train_list needs a reference to a file that contains the training data. 
You can use multiple training files. 
The argument should look something like:
\
\"/path_to_file/file.txt /path_to_other_file/file.txt\"

To validate a model use:
\
--do_validate
\
And provide a
\
--validation_list LIST_FILE

Inferencing works similar but requires a results file:

--results_file RESULT_FILE

Where the results are to be stored. These results can later be used to attach text to individual lines in the PageXML.

A typical training command for training from scratch looks like this:
```bash
docker run -v /scratch:/scratch -v /scratch/tmp/output:/src/src/output/
--gpus all --rm -m 32000m --shm-size 10240m -ti docker.htr python3.8
/src/src/main.py --do_train --train_list
training_all_ijsberg_tiny_train.txt --validation_list
training_all_ijsberg_tiny_val.txt --channels 4 --batch_size 4
--epochs 10 --do_validate --gpu 0 --height 64 --memory_limit 6000
--use_mask --seed 1 --beam_width 10 --model new9 --rnn_layers 3
--rnn_units 256 --use_gru --decay_steps 5000
--batch_normalization --output_charlist output/charlist.charlist
--output output --charlist output/charlist.charlist
--use_rnn_dropout --random_width --elastic_transform
```

Notice in the above docker command that output will be stored in the local disk on:
\
/scratch/tmp/output

Two "tiny" lists are provided. These contain 1000 random training and 1000 random validation lines from the ijsberg dataset.
* training_all_ijsberg_tiny_train
* training_all_ijsberg_tiny_val

For trying out stuff these are really useful.

You can use several preset configs for the neural networks:

--model new9
\
Is very similar to Transkribus' PyLaia models.

--model new10
\
Has larger conv-layers which can be beneficial to especially larger model. 
It will slow down training time, but increase accuracy if you have a large dataset. 
Do not use for smaller data-sets.

--model new11:
\
Larger model with optional dropout in the final dense layer. This should
improve results, but is largely untested. In addition add

--use_dropout for the dropout to be activated.

A typical training command for training using a base model looks like
this:
```bash
docker run -v /scratch:/scratch -v /scratch/tmp/output:/src/src/output/
--gpus all --rm -m 32000m --shm-size 10240m -ti docker.htr python3.8
/src/src/main.py --do_train --train_list
training_all_ijsberg_tiny_train.txt --validation_list
training_all_ijsberg_tiny_val.txt --channels 4 --batch_size 4
--epochs 10 --do_validate --gpu 0 --height 64 --memory_limit 6000
--use_mask --seed 1 --beam_width 10 --model new9 --rnn_layers 3
--rnn_units 256 --use_gru --decay_steps 5000
--batch_normalization --output_charlist output/charlist.charlist
--output output --charlist EXISTING_MODEL.charlist
--use_rnn_dropout --random_width --elastic_transform
--existing_model EXISTING_MODEL
```

You can use the above command if all characters of the new data were also in the previous dataset.

If not you should add
\
--replace_final_layer

Advanced: freeze existing layers and thaw later:

Add these and run for 1 epoch
\
--freeze_conv_layers --freeze_recurrent_layers
\
--replace_final_layer --epochs 1

Next remove freeze & replace parameters and add
\
--thaw

And continue with more epochs.

### Inferencing data


Inferencing data means using the trained models to create a transcription.

For this a convenience script "na-pipeline.sh" is provided.


### Postprocessing

#### Region detecting and cleaning (rule based)

See the "na-pipeline.sh" for an example.

#### Language detection

using defaults (this will produce mwah results):

```bash
docker run --rm -v \$SRC/:\$SRC/ docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionDetectLanguageOfPageXml \$SRC/page/
```

Using custom training files for language inference.

```bash
docker run --rm -v \$SRC/:\$SRC/ docker.loghi-tooling /src/loghi-tooling/minions/target/appassembler/bin/MinionDetectLanguageOfPageXml \$SRC/page/ \$pathOfTrainingSet
```

*pathOfTrainingSet should be a folder with text files.
The name of the text files will be used as the name of the language. 
Make sure to add the correct -v option to docker if you use this*

A training file is a plain text file. 
That should have a name that is a language name that is supported by PageXML. 
So only one language is supported in a file. 
Choose one of the following names: \
https://github.com/PRImA-Research-Lab/PAGE-XML/blob/master/pagecontent/schema/pagecontent.xsd#L1675

The file may have an extension like *.txt*, but it is not mandatory. 
The contents of a file may look something like this:
```text
This is a sentence.
This is a sentence too.
```

Each line in the file will be a training example for the language of the file. 
Blank lines are omitted from the training data.
 

### Trouble shooting

Before reading further check your user id. The dockers are known to only
work for users with the id 1000. We are working on a solution. In Ubuntu
you can check this typing *id* in a shell.

It runs slow: 
- check if you ran the initial "sudo modprobe nvidia_uvm"
- Check if GPU is enabled in the dockers "--gpus all"
- Check if GPU is enabled in the software parameters "--gpu 0" meaning use the first GPU
- Use "top"
- Use "nvidia-smi -l"
- Send screenshots of top and nvidia-smi to Rutger

Loading new docker containers:
-   Start chrome and use the bookmark to go to the download page
-   Download
-   Extract the files to \~/fromWillow
-   Execute "cd \~/; ./loadDockers.sh"

My custom script won't start:
-   Save your script as "your-name-here.sh"
-   Execute "chmod +x your-name-here.sh"
-   Run it: "./your-name-here.sh"

My results of training are not saved:
-   Check docker "-v" mappings

I get the warning:

*"fatal: not a git repository (or any of the parent directories): .git"*
-   You can ignore this warning.

I get some error and don't know what to do:

- Send screenshot to Rutger of just the error. 
Exclude all scan-identifying info.

"PermissionError: \[Errno 13\] Permission denied: \'output/charlist.charlist\'"

If you copy-pasted the example containing "-v /scratch/tmp/output:/src/src/output/"
Execute:
```bash
mkdir -p /scratch/tmp/output
```

And possibly
```bash
sudo chown -R rutger:users /scratch/tmp/output
```

If you get something like:
\
"Not found: No algorithm worked!"
\
This is often an error that is actually caused by running out of memory.
Set --memory_limit to 0 and try again. 
Otherwise decrease number of layers and or units and/or batch_size.

Words are not segmented correctly:

- Note/Warning: new HTR-results will include segmentation on a word-level. 
   The coordinates for this are based on interpolation.
   Do not use these word-level coordinates for anything scientific.
   It should be good enough for highlighting in the interface, do not use for anything else.

### Technical Details

The workflow consists of several steps, of which some are optional. 
The following is a typical workflow when only scans are available and models already have been trained.

- Region-detection using P2PaLA (optional,python/GPU) 
This produces PageXML containing just the text-regions.
- Baseline detection
    -   Option1) P2PaLA normal (labeling of pixels, P2PaLA, python/GPU)
    -   Option2) Baseline-labeling (labeling of pixels, Loghi-linedetection, python/GPU)
    -   Option3) P2PaLA start/end (beta), including detection of start/end of lines (labeling of pixels, P2PaLA, python/GPU)
    -   Baseline-extraction from pixelmaps (uses pixelmaps to detect baselines,java/CPU)
- Text line segmentation (requires baselines, java based/CPU)
Generates segmented text lines.
-   HTR
    -   Option 1: Loghi-HTR (requires segmented textlines, python/GPU and java/CPU)
        -   Loghi-HTR (requires segmented textlines, python/GPU)
        -   MinionLoghiHTRMergePageXML (requires Loghi HTR output, python/GPU and java/CPU)
    -   Option 2: PyLaia-HTR (beta). Requires segmented textlines, python/GPU and java/CPU)
        -   PyLaia-HTR (requires segmented textlines, python/GPU)
        -   MinionPyLaiaMergePageXML (requires PyLaia output and existing PageXML, java/CPU)
-   Region detection based on textline clustering(optional, java/CPU)
-   Applying reading order (optional/java/CPU)
-   Language detection (optional/java/CPU)
-   Cleaning of common errors (optional/java/CPU)
-   Segmenting of Textlines into Words using interpolation. (Optional/Java/CPU)

All code written for GPU can run on CPU, but not vice versa. 
The above workflow is available as a bash script calling docker containers which contain the necessary code.

The following dockers are currently available for HTR and related purposes:
* docker.p2pala_stable.dump (contains stable p2pala)
* docker.p2pala.dump (contains most recent p2pala)
* docker.loghi-tooling.dump (contains all java-code, needs to be split up into separate dockers)
* docker.htr_stable (contains stable Loghi-HTR)
* docker.htr (contains most recent Loghi-HTR)
* docker.pylaia.dump (contains pylaia-HTR, needs some work)
* docker.linedetection.dump (contains Loghi-linedetection, needs some work)

The stable versions are preferred for production. 
The most recent versions are for testing only and might contain serious bugs.


https://github.com/knaw-huc/loghi-htr

Several convenience scripts are available which help in the setting up
and actual inference and training.

- na-pipeline.sh: a script that connects the input/output of various dockers and makes simplifies inferencing to running the command:
\
"./na-pipeline.sh /path/to/inventory_number"
- create_train_data.sh: automatically creates training data for Loghi-HTR given an input folder containing scans and PageXML
- na-pipeline-train.sh: a script that trains loghi-HTR. 
Parameters inside the script need to be edited to point to the correct input data for training.
- p2pala-train-regions.sh: an example starter script for training  p2pala with regions
- p2pala-inference-regions.sh: and example starter script for inferencing p2pala with regions
- p2pala-train.sh: an example script to start baseline training
- p2pala-train-continue.sh: an example script to do baseline training  using a base model
- p2pala-inference.sh: an example on how to inference baselines from scans using an existing model.

These scripts call the docker containers and link the various outputs to inputs for the next tool in the pipeline.

#### Dockers

All the actual software is packaged in docker containers to ease the deployment and interoperability between systems. 
For the actual Dockerfiles and build-scripts please refer to:
https://github.com/knaw-huc/loghi/tree/main/docker

The following dockers are part of the HTR related processes:

###### Docker.pylaia

Provides PyLaia. Should be used in conjunction with NVIDIA Container Toolkit to make use of GPU. 
This docker can be used to create transcriptions for HTR. Scripts for inference are provided, scripts for training are not yet available.

###### Docker.htr

Provides Loghi-HTR. Should be used in conjunction with NVIDIA Container Toolkit to make use of GPU. 
This docker can be used to create transcriptions for HTR. Scripts for inference and training are provided.

###### Docker.linedetection

Provides Loghi linedetection. Should be used in conjunction with NVIDIA Container Toolkit to make use of GPU.
This docker can be used to create pixelmaps for baseline detection. Scripts for inference are provided, scripts for training are not yet available.

###### docker.loghi-tooling

Provides various tools written in Java. 
Not all tools are directly usable for HTR, but are used for other projects. 
Below are listed the tools usable in the HTR process. 
In the future the following tools for HTR will be separated into a separate docker container.

-   MinionExtractBaselines
-   MinionExtractBaselinesStartEndNew3
-   MinionCutFromImageBasedOnPageXMLNew
-   MinionLoghiHTRMergePageXML
-   MinionPyLaiaMergePageXML
-   MinionRecalculateReadingOrderNew
-   MinionDetectLanguageOfPageXml
-   MinionSplitPageXMLTextLineIntoWords

Other tools exists in this docker, but are not described here. 
A more detailed description of the tools can be found below in the section "Tools".

### Tools

In this section various tools that are available for HTR related
processes are described.

##### P2PaLA

Provided via docker: docker.p2pala
\
Source: https://github.com/rvankoert/P2PaLA/
\
Language: Python
\
Runs on: GPU/CPU
\
[inferencing baselines start/end]
\
Requires: scans and a trained model
\
Provides: 3 channel pixel maps
\
[inferencing baseline]
\
Requires: scans and a trained model
\
Provides: 1 channel pixel maps
\
[inferencing regions]
\
Requires: scans and a trained model
\
Provides: PageXML containing regions
\
[training regions]
\
Requires: scans and PageXML
\
Provides: a trained model
\
[training baselines]
\
Requires: scans and PageXML
\
Provides: a trained model
\
[training baselines start/end]
\
Requires: scans and separate PageXML for start and separate for end
\
Provides: a trained model

P2PaLA can be used for baseline detection and region detection. The full
documentation can be found via
https://github.com/rvankoert/P2PaLA/

In the current setup P2PaLA can be used for region detection. Using
P2PaLA in region detection mode will create PageXML for the scans
inferenced.

For baseline detection two options are available: automatic via P2PaLA
immediately generating PageXML or in a two-stage process where P2PaLA
just generates pixel classification maps and the second stage of
updating/creating the PageXML is done via MinionExtractBaselines. The
latter option gives much better results and is preferred. We will assume
that the two-stage-processing is always done.

It is possible to tweak P2PaLA to additionally also detect the beginning
and end of baselines. This is only implemented via two-stage processing.

#### MinionExtractBaselines

Provided via docker: docker.loghi-tooling

Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: 1 channel pixelmaps
\
Provides: PageXML containing baselines

Baseline-extraction from pixelmaps (uses pixelmaps to detect baselines,java/CPU)

#### MinionExtractBaselinesStartEndNew3

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: 3 channel pixelmaps
\
Provides: PageXML containing baselines

Baseline-extraction from pixelmaps when start/end is being used. 
It uses pixelmaps created by P2PaLA in start/end mode or pixelmaps from Loghi-linedetection to detect the actual baselines. 
It provides the second stage for the two-stage baseline detection. 
The three channels refer to baseline, start of baseline and end of baseline. 
The combination of these three elements makes it possible to disentangle baselines that are touching or very close together. 
Typical examples where this helps are: marginalia that are close to the main text and two columns that are close together. 
These easily can go wrong with a single channel approach, but are separated quite nicely with a three channel approach.

#### MinionCutFromImageBasedOnPageXMLNew

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: PageXML containing baselines and original scans
\
Provides: images of segmented text lines
-   Text line segmentation (requires baselines, java based/CPU) \
Textline polygons are updated in the PageXML to reflect the boundaries better.

#### Loghi-HTR

Provided via docker: docker.htr
\
Source: https://github.com/rvankoert/loghi-htr
\
[inferencing]
\
Requires: images of segmented text lines and a trained model
\
Provides: txt files containing text line image filepath and transcription
\
[training]
\
Requires: images of segmented text lines and transcription
\
Provides: a trained model
\
Full help can be viewed by calling "*python3.8 main.py -h*"

This is the core of Loghi HTR and contains neural networks that be trained to read handwritten and printed characters from images of text lines.

#### MinionLoghiHTRMergePageXML (previous name: MinionRutgerHTRMergePageXML)

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: txt files containing text line image filepath and transcription
\
Provides: PageXML

Merges output from Loghi HTR with existing PageXML or creates new PageXML.

#### PyLaia-HTR

Provided via docker: docker.pylaia
\
Source: https://github.com/rvankoert/PyLaia
\
Language: Python/Torch
\
Runs on: CPU/GPU
\
[inferencing]
\
Requires: images of segmented text lines
\
Provides: txt files containing text line image filepath and transcription

Requires segmented textlines, can be used for both training and inference. 
It can convert images of text lines into text using a trained model.

#### MinionPyLaiaMergePageXML

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: txt files containing text line image filepath and transcription and PageXML
\
Provides: PageXML

Provides the mapper that converts PyLaia results to PageXML. 
This is required if you want PyLaia to produce PageXML.

#### MinionRecalculateReadingOrderNew

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: PageXML
\
Provides: PageXML

-   Region detection based on textline clustering(optional, java/CPU)
-   Applying reading order (optional/java/CPU)
-   Cleaning of common errors (optional/java/CPU)

#### MinionDetectLanguageOfPageXml

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: PageXML
\
Provides: PageXML

Detects language based on either preset trainset or custom trainset. 
The language is detected on TextLine-level, TextRegion-level and Page-level.

#### MinionSplitPageXMLTextLineIntoWords

Provided via docker: docker.loghi-tooling
\
Source: https://github.com/knaw-huc/loghi-tooling
\
Language: Java
\
Runs on: CPU
\
Requires: PageXML
\
Provides: PageXML

This can segment Textlines from existing PageXML into Words. 
It uses interpolation Segmenting of Textlines into Words using interpolation.

This produces PageXML containing just the text-regions.

-   (requires segmented textlines, python/GPU and java/CPU)

    -   Loghi-HTR (requires segmented textlines, python/GPU)

    -   Loghi-HTR-mapper (requires segmented textlines, python/GPU and java/CPU)

## Installation

### Workstation Installation

Typical installation should be done using docker-containers on linux.
Tested linux installations are ubuntu 20.04 and 22.04. Having a GPU (nvidia 2070 or better) is preferred. 
Tested with 16GB ram minimum although 8GB should also work. More ram is better, enough CPU-power should be available to keep the GPU running. 
Especially when training with data-augmentation or in inferencing mode. 
SSD's for tmp/scratch give a considerable speedup.

- Install imagemagick
- Install docker
- Install nvidia container runtime: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker
- Download the dockers from  https://surfdrive.surf.nl/files/index.php/s/YgME8Ewbk3uWbMe
\
Using the provided password
- For each docker do: docker load \< DOCKER_FILENAME_HERE.dump
- Download the convenience scripts for inferencing and training
- Optionally tweak some parameters in the scripts to use different models/settings and run against some data.

## Source Installation

[incomplete]
\
This is intended for development purposes only.
```
mkdir \~/src

cd \~/src
```
Install loghi-htr using instruction on: https://github.com/knaw-huc/loghi-htr
\
Install loghi-tooling using instruction on: https://github.com/knaw-huc/loghi-tooling

