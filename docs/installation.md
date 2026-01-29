# Installation

## OS requirement
Loghi works best on Linux. Although it can run on Windows using WSL, it is not the recommended approach. Mac's are currently not supported (see also [Does Loghi work on Apple Silicon (M1/M2/M3)?](#does-loghi-work-on-apple-silicon-m1m2m3)).

## How to install Loghi
### 1. Cloning the repository
Begin by cloning the Loghi repository to access the toolkit and navigate into the directory:

```bash
git clone https://github.com/knaw-huc/loghi.git
cd loghi
```
### 2. Docker images
For most users, Docker offers the easiest and most straightforward way to deploy and use Loghi. If Docker is not installed on your machine, follow [these instructions](https://docs.docker.com/engine/install/) to install it.
> [!CAUTION]
> Loghi currently does not work with the snap version of Docker out of the box, when installing please use the `apt` version. See Issue https://github.com/knaw-huc/loghi/issues/40 for updates

You can either use pre-built Docker images, or build them yourself. 
#### 2.1 Pull pre-built images
Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi):

```bash
docker pull loghi/docker.laypa
docker pull loghi/docker.htr
docker pull loghi/docker.loghi-tooling
```

#### 2.2 Build from source
As an alternative to using the tested and prebuild docker images, you can build the Docker images with the latest code yourself:

```bash
git submodule update --init --recursive
cd docker
./buildAll.sh
```

### 3. Download models
Go to
https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP
and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR).

suggestion for laypa: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/laypa/general/baseline2?accept=zip

suggestion for loghi-htr that should give some results: http://surfdrive.surf.nl/public.php/dav/files/YA8HJuukIUKznSP/loghi-htr/generic-2023-02-15?accept=zip. It is not perfect, but a good starting point. It should work ok on 17th and 18th century handwritten dutch. For best results always finetune on your own specific data.

If you downloaded a zip: you should unzip it first.

### 4. Update paths and run Loghi
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

## Problems with installation?
If you run into errors, please check the [troubleshooting section](troubleshooting.md). If you still have issues, please open an issue on GitHub with as much detail as possible and make sure to include the error message you received and the version of Loghi. This will help us assist you more effectively.


## GPU Acceleration

To harness the full power of Loghi for faster processing, running it on a GPU is recommended. For users with NVIDIA GPUs, ensure you have NVIDIA Docker installed or your Docker setup supports GPU acceleration. This allows Loghi to utilize GPU resources for processing tasks, significantly speeding up operations like image segmentation with Laypa and text recognition with Loghi HTR.

Setting up Docker to run with GPU support involves installing NVIDIA's Docker extension and specifying the use of a GPU when running a Docker container. For detailed instructions on enabling Docker to work with your NVIDIA GPU, please refer to the official NVIDIA Docker documentation.

Note: Running Loghi with GPU acceleration is particularly beneficial for processing large datasets or when high throughput is required. Ensure your system meets the necessary hardware and software requirements for optimal performance.
