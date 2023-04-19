# loghi


```bash
# to get started:
git clone git@github.com:knaw-huc/loghi.git
cd loghi
```

## Get the dockers
If you want to build the dockers yourself with the latest code:
```bash
# for initial pulling of submodules use:
git submodule update --init --recursive
git pull --recurse-submodules
cd docker
./buildAll.sh
```

otherwise just go ahead and use the default dockers on dockerhub.

## Inference

But first go to:
https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP
and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR).

suggestion for laypa:
- general

suggestion for loghi-htr that should give some results:
- generic-2023-02-15

It is not perfect, but a good starting point. It should work ok on 17th and 18th century handwritten dutch. For best results always finetune on your own specific data.

edit the na-pipeline.sh using vi, nano, other whatever editor you prefer. We'll use nano in this example

```bash
nano na-pipeline.sh
```
Look for the following lines:
```
LAYPAMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPAMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE
```
and update those paths with the location of the files you just downloaded. If you downloaded a zip: you should unzip it first.

Save the file and run it:
```bash
./na-pipeline.sh /PATH_TO_FOLDER_CONTAINING_IMAGES
```
replace /PATH_TO_FOLDER_CONTAINING_IMAGES with a valid directory containing images (.jpg is preferred/tested) directly below it.

The file should run for a short while if you have a good nvidia GPU and nvidia-docker setup. It might be a long while if you just have CPU available. It should work either way, just a lot slower on CPU.


When it finishes without errors a new folder called "page" should be created in the directory with the images. This contains the PageXML output.

## Training an HTR model

### Input data

Expected structure
```text
training_data_folder
|- train_list.txt
|- val_list.txt
|- image1_snippets
    |-snippet1.png
    |-snippet2.png
```

`train_list.txt` should look something something like:
```text
/path/to/training_data_folder/image1_snippets/snippet1.png	textual representation of snippet 1
/path/to/training_data_folder/image1_snippets//snippet2.png text on snippet 2
```
n.b. path to image and textual representation should be separated by a tab.

```bash
nano na-pipeline-train.sh
```

Find the following lines:
```text
listdir=INSERT_FULL_PATH_TO_TRAINING_DATA_FOLDER
trainlist=INSERT_FULL_PATH_TO_TRAINING_DATA_LIST
validationlist=INSERT_FULL_PATH_TO_VALIDATION_DATA_LIST
```
In this exampole: 
```text
listdir=/full/path/to/training_data_folder
trainlist=/full/path/to/training_data_folder/train_list.txt
validationlist=/full/path/to/training_data_folder/val_list.txt
```

```bash
./na-pipline-train.sh
```

# for later updates use:
```bash
git pull --recurse-submodules
```

