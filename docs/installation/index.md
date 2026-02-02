# Installation

Loghi works best on Linux. Although it can run on Windows using WSL, it is not the recommended approach. macOS is currently not supported (see also [FAQ](FAQ.md)).

Here is a step-by-step guide for installing Loghi on Linux. If you run into errors during installation, please check the [troubleshooting page](troubleshooting.md).

## 1. Go to the terminal
The terminal is the place where you send commands to your computer. On a Linux desktop, you can access the terminal by pressing `Ctrl + Alt + T`. Alternatively, you can look for "Terminal" in your applications menu.

## 2. Clone the repository
Begin by cloning the Loghi repository to access the toolkit and navigate into the directory. Please copy the following commands, paste them into your terminal, then press `Enter`:

```bash
git clone https://github.com/knaw-huc/loghi.git
cd loghi
```

```{tip}
The usual copy-paste shortcuts, `Ctrl + C` and `Ctrl + V`, don't work in the terminal. Use `Ctrl + Shift + C` and `Ctrl + Shift + V` to copy and paste instead.
```

## 3. Install Docker
Docker is a tool that offers the easiest and most straightforward way to deploy and use Loghi. Run the following command to see if Docker is installed:
```bash
docker --version
```
### 3.1 "Docker version 29.1.2, build 890dcca"
A message similar to this shows the version of Dokcer installed. You may now process to [Step 4](#build-docker-images). 

### 3.2 "docker: command not found"
If you see "docker: command not found", please follow 
[the official guide](https://docs.docker.com/engine/install/) to install Docker. First you need to choose the right Linux platform. 
Don't know what platform your machine uses? Run the following command in the terminal:
```bash

<!-- question: copy paste from the page, or redirect the user? -->

```{note}
Loghi currently does not work with the snap version of Docker out of the box, when installing please use the `apt` version. See Issue https://github.com/knaw-huc/loghi/issues/40 for updates
```

## 4 Build Docker images
A Docker image is a special package that contains . There are two ways to build Docker images: you can either use pre-built ones, or build them yourself. 
### 4.1 Get pre-built images
Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi):

```bash
docker pull loghi/docker.laypa
docker pull loghi/docker.htr
docker pull loghi/docker.loghi-tooling
```

### 4.2 Build from source
As an alternative to using the tested and prebuild docker images, you can build the Docker images with the latest code yourself:

```bash
git submodule update --init --recursive
cd docker
./buildAll.sh
```

## 5. Download models
Go to
https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP
and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR).

suggestion for laypa: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip

suggestion for loghi-htr that should give some results: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip. It is not perfect, but a good starting point. It should work ok on 17th and 18th century handwritten dutch. For best results always finetune on your own specific data.

If you downloaded a zip: you should unzip it first.

## 6. Update paths and run Loghi
Edit the [`scripts/inference-pipeline.sh`](scripts/inference-pipeline.sh) using vi, nano, other whatever editor you prefer. We'll use nano in this example

```bash
nano scripts/inference-pipeline.sh
```
Look for the following lines:
```
LAYPABASELINEMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPABASELINEMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE
```
and update those paths with the location of the files you just downloaded in Step 3. Note that "FULL_PATH_TO_LOGHI_HTR_MODEL" refers to the entire folder containing the "model" folder and other documents.

If you do not have a NVIDIA-GPU and nvidia-docker setup, additionally change

```text
GPU=0
```
to
```text
GPU=-1
```
It will then run on CPU, which will be very slow. If you are using the pretrained model and run on CPU: please make sure to download the Loghi-htr model starting with "float32-". This will run faster on CPU than the default mixed_float16 models.

Save the file and run it:
```bash
./scripts/inference-pipeline.sh /PATH_TO_FOLDER_CONTAINING_IMAGES
```
replace /PATH_TO_FOLDER_CONTAINING_IMAGES with a valid directory containing images (.jpg is preferred/tested) directly below it.

The file should run for a short while if you have a good nvidia GPU and nvidia-docker setup. It might be a long while if you just have CPU available. It should work either way, just a lot slower on CPU.

When it finishes without errors a new folder called "page" should be created in the directory with the images. This contains the PageXML output.