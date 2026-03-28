# Installation

Here is a step-by-step guide for installing Loghi on Linux. If you run into errors during installation, please check the [troubleshooting page](../questions/troubleshooting).

(clone-repo)=
## 1. Clone the Repository

The first step is to clone the Loghi repository to access the toolkit and navigate into the directory. Copy the following commands, pasting them into your terminal, and press `Enter`:
```bash
git clone https://github.com/knaw-huc/loghi.git
cd loghi
```

(install-docker)=
## 2. Install Docker

Docker is a tool that offers the easiest and most straightforward way to deploy and use Loghi. Run the following command to see if Docker has already been installed in your machine:
```bash
docker --version
```
**Possible outcomes:**

1. **A message similar to "Docker version 29.1.2, build 890dcca"**: Docker has been installed. You can proceed to [build Docker images](build_docker_images).

2. **A message reading "docker: command not found"**: No Docker installation has been found. Follow 
[the official guide](https://docs.docker.com/engine/install/)[^docker-install] to install Docker using the `apt` version. 

:::{important}
When installing Docker:
1. Make sure to choose the right Linux platform. Don't know what platform your machine uses? Run the following command in the terminal:
    ```bash
    lsb_release -a
    ```
    You will then see the name of the platform listed after "Distributor ID" or "Description" (e.g. Ubuntu, Fedora, Debian).

2. Make sure that you install Docker using the `apt` repository, as Loghi might not work with the snap version of Docker. 
:::

(build-docker-images)=
## 3. Build Docker Images

A Docker image is not a picture, but a special package that prepares the environment for running tools. There are two ways to build Docker images: you can either use pre-built ones, or build them yourself. Both could take some time to complete.
::::{tab-set}

:::{tab-item} Option 1: Get pre-built images

Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi)[^docker-hub] by running the following commands:

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

(set-up-gpu)=
## 4. Set up GPU Acceleration with NVIDIA (optional)

For users with NVIDIA GPUs, running Loghi with GPU acceleration significantly speeds up operations like image segmentation with Laypa and text recognition with Loghi HTR. This is particularly beneficial for processing large datasets.

:::{note}
This setup is optional. If you skip this section, Loghi will run on CPU (just slower). You can always come back and set up GPU support later.
:::

### 4.1 Check for NVIDIA GPU

Check if you have an NVIDIA GPU:
```bash
lspci | grep -i nvidia
```

**Possible outcomes:**

1. **Nothing appears**: You don't have an NVIDIA GPU or it's not detected. Skip to [Download models](download-models) and continue with CPU mode.

2. **Output appears** (e.g., "01:00.0 VGA compatible controller: NVIDIA Corporation GeForce GTX 1080"): You have an NVIDIA GPU. Continue to the next step.

### 4.2 Check for NVIDIA drivers

Check if NVIDIA drivers are installed:

```bash
nvidia-smi
```

**Possible outcomes:**

1. **Shows GPU information**: Drivers are installed! Note the CUDA version shown at the top. Continue to install NVIDIA Container Toolkit below.

2. **"command not found" or error**: NVIDIA drivers are not installed. Install them:
   ```bash
   # For Ubuntu/Debian
   sudo ubuntu-drivers autoinstall
   # Or manually install the driver:
   # sudo apt install nvidia-driver-XXX  (replace XXX with version)
   ```
   After installation, reboot your system and run `nvidia-smi` again to verify.

3. **"NVIDIA-SMI has failed"**: Drivers are installed but not working properly. Try rebooting or reinstalling the drivers.

### 4.3 Install NVIDIA Container Toolkit

Follow the [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)[^nvidia-toolkit] to install the NVIDIA Container Toolkit. This allows Docker to access your GPU.

(download-models)=
## 5. Download Models

Go to [our SURFdrive page](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP)[^surfdrive-models] and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR): click on the three dots on the right of the corresponding folder and select "Download", or tick the box preceding the corresponding folder and click the "Download" that then appears. Also be reminded to unzip the downloaded files for the use in the next step.


::::{tab-set}

:::{tab-item} Recommended models for NVIDIA GPU

If you have a NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip)[^laypa-baseline2] and [loghi-htr generic-2023-02-15](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip)[^htr-generic] (it works ok on 17th and 18th century handwritten Dutch; if you want best results, see the [training page](../usage/training) to finetune the models on your specific data).

:::

:::{tab-item} Recommended models for CPU

If you do not have a NVIDIA GPU, we recommend these two models: [laypa general baseline2](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip)[^laypa-baseline2] and the [float32 Loghi-htr model](http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/float32-generic-2023-02-15?accept=zip)[^htr-float32] (it will run faster on CPU than the other recommended model, which is mixed_float16).

:::

::::

## 6. Update Paths

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

(run-loghi)=
## 7. Run Loghi

Run the script with the following command:
```bash
./scripts/inference-pipeline.sh /PATH_TO_FOLDER_CONTAINING_IMAGES
```
You need to replace `/PATH_TO_FOLDER_CONTAINING_IMAGES` with a valid directory containing images (.jpg is preferred/tested) directly below it. For example, if the images are placed in the folder `/home/user/images`, the command should be:

```bash
./scripts/inference-pipeline.sh /home/user/images
```

It would run for a short while if you have a good NVIDIA GPU and NVIDIA Docker setup, and much longer if you don't. When it finishes without errors, a new folder called "page" should be created in the directory with the images, containing the output in PageXML format.

:::{tip}
To learn how to read and understand the PageXML output files, see [Understanding Loghi Output](../usage/output).
:::

[^docker-install]: https://docs.docker.com/engine/install/
[^docker-hub]: https://hub.docker.com/u/loghi
[^nvidia-toolkit]: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
[^surfdrive-models]: https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP
[^laypa-baseline2]: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip
[^htr-generic]: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip
[^htr-float32]: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/float32-generic-2023-02-15?accept=zip