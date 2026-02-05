# Installation

<!-- content being updated-->

Here is a step-by-step guide for installing Loghi on Linux. If you run into errors during installation, please check the [troubleshooting page](../questions/troubleshooting).

## 1. Prepare the environment
### 1.1 Install Docker

Docker is a tool that offers the easiest and most straightforward way to deploy and use Loghi. Run the following command to see if Docker has already been installed in your machine:
```bash
docker --version
```
If you get a message similar to "Docker version 29.1.2, build 890dcca", you can proceed to [build Docker images](#build-docker-images). 
If you see "docker: command not found", please follow 
[the official guide](https://docs.docker.com/engine/install/) to install Docker using the `apt` version. 

#### Reminders
1. Make sure to choose the right Linux platform. Don't know what platform your machine uses? Run the following command in the terminal:
```bash
lsb_release -a
```
You will then see the name of the platform listed after "Distributor ID" or "Description" (e.g. Ubuntu, Fedora, Debian).

2. Make sure that you install Docker using the `apt` repository, as Loghi might not work with the snap version of Docker. 

### 1.2 Set up GPU acceleration with NVIDIA

Let's first check if you have an NVIDIA GPU. Run this code in your terminal:
```bash
lspci | grep -i nvidia
```
Some message like "01:00.0 VGA compatible controller: NVIDIA Corporation GeForce GTX 1080" means that you have it.

If nothing appears, you either don't have an NVIDIA GPU or the drivers aren’t installed. 


<!-- content to be updated -->

### 1.3 Build Docker images

A Docker image is not a picture, but a special package that prepares the environment for running tools. There are two ways to build Docker images: you can either use pre-built ones, or build them yourself. Both could take some time to complete, so please be patient.
::::{tab-set}

:::{tab-item} Option 1: Get pre-built images

Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi) by running the following commands:

```bash
docker pull loghi/docker.laypa
docker pull loghi/docker.htr
docker pull loghi/docker.loghi-tooling
```
:::

:::{tab-item} Option 2: Build from source

As an alternative to using the the pre-built Docker images, you can build them yourself. The following commands update the downloaded scripts to the latest version and build the Docker images:

```bash
git submodule update --init --recursive
./docker/buildAll.sh
```
:::
::::

## 2. Download and run Loghi
### 2.1 Clone the repository

Begin by cloning the Loghi repository to access the toolkit and navigate into the directory. Please copy the following commands, paste them into your terminal, then press `Enter`:

```bash
git clone https://github.com/knaw-huc/loghi.git
cd loghi
```

### 2.2 Download models

Go to [this webpage](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP) and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR): click on the three dots on the right of the corresponding folder and select "Download", or tick the box preceding the corresponding folder and click the "Download" that then appears.

Recommended models:
::::{tab-set}

:::{tab-item} Option 1: With NVIDIA GPU
If you have the NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip) and [loghi-htr generic-2023-02-15](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip) (it works ok on 17th and 18th century handwritten Dutch; if you want best results, see [training](usage/training.md) to finetune the models on your specific data).
:::

:::{tab-item} Option 2: Without NVIDIA GPU
If you do not have the NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip) and the [float32 Loghi-htr model](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/float32-generic-2023-02-15?accept=zip) (it will run faster on CPU than the other recommended model, which is mixed_float16).

:::
::::

Please be reminded to unzip the downloaded files, which will each become a folder containing a `.yaml` file and a `.pth` file.

### 2.3 Update paths

Edit the `scripts/inference-pipeline.sh` script downloaded in Step 2 with an editor of your choice. We'll use nano in this example so that you can edit it directly in the terminal:
```bash
nano scripts/inference-pipeline.sh
```
Look for the following lines:
```text
LAYPABASELINEMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPABASELINEMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE
```
and update those paths with the location of the files you just downloaded in the previous step. Note that "FULL_PATH_TO_LOGHI_HTR_MODEL_HERE" refers to the entire folder containing the "model" folder and other documents.

If you do not have a NVIDIA GPU and NVIDIA-Docker setup, additionally change the line
```text
GPU=0
```
to
```text
GPU=-1
```

After editing, save the script with `Ctrl + S`, and press `Ctrl + X` to exit the editor.

### 2.4 Run Loghi

Run the script with the following command:
```bash
./scripts/inference-pipeline.sh /PATH_TO_FOLDER_CONTAINING_IMAGES
```
You need to replace `/PATH_TO_FOLDER_CONTAINING_IMAGES` with a valid directory containing images (.jpg is preferred/tested) directly below it. For example, if the images are placed in the folder `/home/user/images`, the command should be:

```bash
./scripts/inference-pipeline.sh /home/user/images
```

It might be a long while if you don't have a NVIDIA GPU. When it finishes without errors, a new folder called "page" should be created in the directory with the images. It contains the PageXML output.