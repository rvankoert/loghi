# Installation

<!-- content being updated-->

Here is a step-by-step guide for installing Loghi on Linux. If you run into errors during installation, please check the [troubleshooting page](../questions/troubleshooting).

## 1. Prepare the environment
### 1.1 Install Docker

Docker is a tool that offers the easiest and most straightforward way to deploy and use Loghi. Run the following command to see if Docker has already been installed in your machine by copying it, pasting it into your terminal, then pressing `Enter`:
```bash
docker --version
```
If you get a message similar to "Docker version 29.1.2, build 890dcca", you can proceed to [build Docker images](#13-build-docker-images).
If you see "docker: command not found", please follow 
[the official guide](https://docs.docker.com/engine/install/) to install Docker using the `apt` version. 

:::{important}
1. Make sure to choose the right Linux platform. Don't know what platform your machine uses? Run the following command in the terminal:
```bash
lsb_release -a
```
You will then see the name of the platform listed after "Distributor ID" or "Description" (e.g. Ubuntu, Fedora, Debian).

2. Make sure that you install Docker using the `apt` repository, as Loghi might not work with the snap version of Docker. 
:::

### 1.2 Set up GPU acceleration with NVIDIA (optional)
<!-- section prepared by claude, to be verified-->

For users with NVIDIA GPUs, it is recommended to run Loghi on GPU for faster processing. This allows Loghi to utilize GPU resources for processing tasks, significantly speeding up operations like image segmentation with Laypa and text recognition with Loghi HTR. Running Loghi with GPU acceleration is particularly beneficial for processing large datasets or when high throughput is required.

:::{note}
This setup is optional. You can skip it if you don't have a NVIDIA GPU or if you don't want to deal with GPU setup. Loghi will work on CPU, just significantly slower.
:::

#### 1.2.1 Check for NVIDIA GPU

Let's first check if you have an NVIDIA GPU. Run this command in your terminal:
```bash
lspci | grep -i nvidia
```

**Possible outcomes:**

1. **Nothing appears**: You either don't have an NVIDIA GPU, or it's not detected. Skip to [Build Docker images](#13-build-docker-images) and continue without GPU acceleration.

2. **Output appears** (e.g., "01:00.0 VGA compatible controller: NVIDIA Corporation GeForce GTX 1080"): You have an NVIDIA GPU. 

#### 1.2.2 Check for NVIDIA drivers
Now check if NVIDIA drivers are installed.

```bash
nvidia-smi
```

**Possible outcomes:**

1. **Shows GPU information**: Drivers are installed! Note the CUDA version shown at the top of the output. Continue to install NVIDIA Container Toolkit below.

2. **"command not found" or error**: NVIDIA drivers are not installed. Install them:
   ```bash
   # For Ubuntu/Debian
   sudo ubuntu-drivers autoinstall
   # Or manually install the driver:
   # sudo apt install nvidia-driver-XXX  (replace XXX with version)
   ```
   After installation, reboot your system and run `nvidia-smi` again to verify.

3. **"NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver"**: Drivers are installed but not working properly. Try rebooting or reinstalling the drivers.

:::{tip}
If you're unsure about your GPU or don't want to deal with GPU setup, you can skip this section. Loghi will work on CPU, just significantly slower.
:::

#### 1.2.3 Install NVIDIA Container Toolkit

Follow the [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) to install the NVIDIA Container Toolkit.

### 1.3 Build Docker images

A Docker image is not a picture, but a special package that prepares the environment for running tools. There are two ways to build Docker images: you can either use pre-built ones, or build them yourself. Both could take some time to complete.
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

Begin by cloning the Loghi repository to access the toolkit and navigate into the directory:

```bash
git clone https://github.com/knaw-huc/loghi.git
cd loghi
```

### 2.2 Download models

Go to [this webpage](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP) and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR): click on the three dots on the right of the corresponding folder and select "Download", or tick the box preceding the corresponding folder and click the "Download" that then appears. Also be reminded to unzip the downloaded files for the use in the next step.


::::{tab-set}

:::{tab-item} Recommended models for NVIDIA GPU

If you have a NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip) and [loghi-htr generic-2023-02-15](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip) (it works ok on 17th and 18th century handwritten Dutch; if you want best results, see [training](../usage/training) to finetune the models on your specific data).

:::

:::{tab-item} Recommended models for CPU

If you do not have a NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip) and the [float32 Loghi-htr model](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/float32-generic-2023-02-15?accept=zip) (it will run faster on CPU than the other recommended model, which is mixed_float16).

:::

::::

### 2.3 Update paths

Edit the `scripts/inference-pipeline.sh` script downloaded in the cloned repository with an editor of your choice. We'll use nano in this example because it allows you to directly change the script in the terminal. Enter this command in the terminal to open the script:
```bash
nano scripts/inference-pipeline.sh
```

Look for the following lines:
```text
LAYPABASELINEMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPABASELINEMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE
```
and update those paths with the location of the files you just downloaded in the previous step. Note that `FULL_PATH_TO_LOGHI_HTR_MODEL_HERE` refers to the entire folder containing the "model" folder and other documents.

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

It might be a long while if you don't have a NVIDIA GPU. When it finishes without errors, a new folder called "page" should be created in the directory with the images, containing the output in PageXML format.

:::{tip}
To learn how to read and understand the PageXML output files, see [Understanding Loghi Output](../usage/output).
:::