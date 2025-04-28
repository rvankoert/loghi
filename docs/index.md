# Loghi: Handwritten Text Recognition Toolkit

Loghi is a comprehensive toolkit designed for Automatic Text Recognition (ATR), a combination of both Handwritten Text Recognition (HTR) and Optical Character Recognition (OCR), offering an accessible approach to transcribing historical documents and training models for specialized needs. This README provides a quick start guide for using Loghi, including how to install, run inference, train new models, and utilize our scripts for these tasks.

## Table of Contents
- [Loghi: Handwritten Text Recognition Toolkit](#loghi-handwritten-text-recognition-toolkit)
  - [Table of Contents](#table-of-contents)
  - [Introduction to Loghi](#introduction-to-loghi)
    - [Laypa: Layout Analysis and Segmentation](#laypa-layout-analysis-and-segmentation)
    - [Loghi Tooling: Pre and Post-Processing Toolkit](#loghi-tooling-pre-and-post-processing-toolkit)
    - [Loghi HTR: Text Transcription](#loghi-htr-text-transcription)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Docker Images](#docker-images)
    - [GPU Acceleration](#gpu-acceleration)
  - [Using Loghi](#using-loghi)
  - [Running the Web Service](#running-the-web-service)
  - [Updates](#updates)
  - [Gradio Demo](gradio.md)
  - [Contributing](#contributing)
  - [FAQ](#faq)
    - [Does Loghi work on Apple Silicon (M1/M2/M3)?](#does-loghi-work-on-apple-silicon-m1m2m3)

## Introduction to Loghi

The Loghi framework is designed to streamline the process of Automatic Text Recognition (ATR), from analyzing document layouts to transcribing handwritten text into digital format. At the core of Loghi are three critical components, each responsible for a distinct aspect of the HTR pipeline:

### Laypa: Layout Analysis and Segmentation

[Laypa](https://github.com/knaw-huc/laypa/) specializes in the segmentation of documents, identifying different regions like paragraphs, page numbers, and most importantly, baselines within the text. Utilizing a sophisticated architecture based on a ResNet backbone and a feature pyramid network, Laypa performs pixel-wise classifications to detect these elements. Built on the [detectron2](https://github.com/facebookresearch/detectron2) framework, its output facilitates further processing by converting the classifications into instances—either as masks or directly into PageXML format. This segmentation is crucial for preparing documents for OCR/HTR processing, ensuring that text regions are accurately recognized and extracted.

### Loghi Tooling: Pre and Post-Processing Toolkit

The [Loghi Tooling](https://github.com/knaw-huc/loghi-tooling) module offers a suite of utilities designed to support the Loghi framework, handling tasks that occur both between and following the machine learning stages. This includes cutting images into individual text lines, integrating the transcription results into the PageXML, and recalculating reading orders among others. Its role is vital in managing the workflow of document preparation and finalization, streamlining the transition from raw image to processed text.

### Loghi HTR: Text Transcription

At the heart of the Loghi framework, the [Loghi HTR](https://github.com/knaw-huc/loghi-htr) module is responsible for the actual transcription of text from images. This system is not limited to handwritten text, as it is also capable of processing machine-printed text. By converting line images into textual data, Loghi HTR forms the final step in the HTR process, bridging the gap between visual data and usable digital text.

Together, these components form a comprehensive ecosystem for handling HTR tasks, from initial layout analysis to the final transcription of text. The Loghi framework offers a modular approach, allowing users to engage with individual components based on their specific needs, while also providing a cohesive solution for end-to-end handwritten text recognition.

## Quick Start

### Installation

Loghi works best on Linux. Although it can run on Windows using WSL, it is not the recommended approach. macOS devices are currently not supported.
Begin by cloning the Loghi repository to access the toolkit and navigate into the directory:

```bash
git clone git@github.com:knaw-huc/loghi.git
cd loghi
```

### Docker Images

> [!CAUTION]
> Loghi currently does not work with the snap version of Docker out of the box, when installing please use the `apt` version. See Issue https://github.com/knaw-huc/loghi/issues/40 for updates

For most users, Docker offers the easiest and most straightforward way to deploy and use Loghi. Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi):

```bash
docker pull loghi/docker.laypa
docker pull loghi/docker.htr
docker pull loghi/docker.loghi-tooling
```

If Docker is not installed on your machine, follow [these instructions](https://docs.docker.com/engine/install/) to install it.

But first go to: 
[https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP?path=%2Flaypa#](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP?path=%2Flaypa#)

and download a laypa model (for detection of baselines) and a loghi-htr model (for HTR).

suggestion for laypa:
```text
general - baseline2
```
click the three dots on the right and select "download" to download the model. It will be a zip file. Unzip it and you should have a folder with a .yaml and a .pth file in it.

[https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP?path=%2Floghi-htr#](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP?path=%2Floghi-htr#)
suggestion for loghi-htr that should give some results:
```text
generic-2023-02-15
```
click the three dots on the right and select "download" to download the model. It will be a zip file. Unzip it and you should have a folder with a .yaml and a .pth file in it.

It is not perfect, but a good starting point. It should work ok on 17th and 18th century handwritten dutch. For best results always finetune on your own specific data.

edit the [`scripts/inference-pipeline.sh`](scripts/inference-pipeline.sh) using vi, nano, code, other whatever editor you prefer. We'll use nano in this example

```bash
nano scripts/inference-pipeline.sh
```
Look for the following lines:
```
LAYPABASELINEMODEL=INSERT_FULL_PATH_TO_YAML_HERE
LAYPABASELINEMODELWEIGHTS=INSERT_FULLPATH_TO_PTH_HERE
HTRLOGHIMODEL=INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE
```
and update those paths with the location of the files you just downloaded. If you downloaded a zip: you should unzip it first. Make sure to use the full path; for example:
```text
LAYPABASELINEMODEL=/home/user/Downloads/laypa-baseline2.yaml
```

if you do not have a NVIDIA-GPU and nvidia-docker setup additionally change

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

The file should run for a short time if you have a good nvidia GPU and nvidia-docker setup. It might be a lot longer if you just have CPU available. It should work either way, just a lot slower on CPU.

When it finishes without errors a new folder called "page" should be created in the directory with the images. This contains the PageXML output.

If you run into errors, please check the [troubleshooting section](#troubleshooting) of the README. If you still have issues, please open an issue on GitHub with as much detail as possible and make sure to include the error message you received and the version of Loghi. This will help us assist you more effectively.


## Troubleshooting

#### Common Issues
- For runtime errors, verify that the paths to your models are correct and that the models are compatible with your version of Loghi.
- If you experience performance issues, consider checking your GPU settings and ensuring that Docker is configured to utilize GPU resources effectively. On Linux you could use `nvidia-smi` or `nvtop` to check if the GPU is being used correctly.
- If you have a specific error message, search the issues to see if someone else has encountered the same problem. If not, please open a new issue with detailed information about your setup and the error.
- For any other issues, please refer to the [GitHub Issues](https://github.com/knaw-huc/loghi/issues).
- If you get the message "bash: ./scripts/inference-pipeline.sh: Permission denied" when trying to run the inference script, you may need to change the permissions of the script. You can do this by running:
```bash
chmod +x scripts/inference-pipeline.sh
```


#### using Docker
- Ensure that Docker is installed and running correctly on your system.
- If you encounter permission issues, try adding your user to the Docker group.
- If you experience issues with GPU support, ensure that NVIDIA drivers and Docker are correctly configured to utilize GPU resources.
- If you run into path issues, ensure that everything is mapped correctly using volume mappings.

#### using the source code directly
- If you encounter problems during installation, ensure that all dependencies are correctly installed.
- If you are using a virtual environment, ensure that it is activated before running any commands.
- If you are using a custom dataset, ensure that it is formatted correctly and that the paths to the images and annotations are correct.


### Build dockers from source

As an alternative to using the tested and prebuild docker images, you can build the Docker images with the latest code yourself:

```bash
git submodule update --init --recursive
cd docker
./buildAll.sh
```

### GPU Acceleration

To harness the full power of Loghi for faster processing, running it on a GPU is recommended. For users with NVIDIA GPUs, ensure you have NVIDIA Docker installed or your Docker setup supports GPU acceleration. This allows Loghi to utilize GPU resources for processing tasks, significantly speeding up operations like image segmentation with Laypa and text recognition with Loghi HTR.

Setting up Docker to run with GPU support involves installing NVIDIA's Docker extension and specifying the use of a GPU when running a Docker container. For detailed instructions on enabling Docker to work with your NVIDIA GPU, please refer to the official NVIDIA Docker documentation.

Note: Running Loghi with GPU acceleration is particularly beneficial for processing large datasets or when high throughput is required. Ensure your system meets the necessary hardware and software requirements for optimal performance.

## Using Loghi

For detailed instructions on running inference, training new models, and other advanced features, refer to the [`scripts`](scripts) directory in this repository. There, you'll find sample scripts and a README designed to guide you through these processes efficiently:

- [`create-train-data.sh`](scripts/create-train-data.sh) for preparing training data for HTR models.
- [`generate-synthetic-images.sh`](scripts/generate-synthetic-images.sh) for generating synthetic text lines.
- [`htr-train-pipeline.sh`](scripts/htr-train-pipeline.sh) for training new HTR models.
- [`inference-pipeline.sh`](scripts/inference-pipeline.sh) for transcribing complete scans.

These scripts simplify the process of using Loghi for your HTR projects.

> [!TIP]
> The [Loghi-HTR repository](https://github.com/knaw-huc/loghi-htr/) contains a config folder that provides a few quick-start configurations for running Loghi-HTR. These configurations can be used to quickly set up more advanced training and inference pipelines, allowing you to get started with Loghi-HTR in no time. Simply copy the desired config file, adjust the parameters as needed, and run Loghi-HTR using the `--config_file` parameter.


## Updates

To stay updated with the latest versions of the submodules, run:

```bash
git submodule update --recursive --remote
```

This ensures you have access to the most recent (though possibly unstable) versions of the code.


## Contributing

We welcome contributions to Loghi and its components! Whether you encounter issues, have suggestions for improvements, or wish to contribute code, we encourage you to engage with us. Contributions can be made to this repository or any of its subdirectories, which include other component repositories.

Here's how you can contribute:

1. **Report Issues:** Found a bug or have a feature idea? Open an issue in the relevant GitHub repository. Whether it's for the main project or a specific component, your feedback is invaluable. Please provide as much detail as possible to help us understand and address the issue effectively.

2. **Submit Pull Requests:** If you've developed a fix or enhancement, we'd love to see it! Submit a pull request with your changes. Ensure your contributions are well-documented and adhere to the project's coding standards. Your code should be submitted to the appropriate repository, whether it's the main one or a component-specific repo.

3. **Fork and Enhance:** Feel free to fork any of the repositories within the project's ecosystem. Whether you're making broad improvements or tinkering with a specific component, your innovation is welcome. Share your forks and pull requests with us; we're eager to incorporate community-driven enhancements!

Contributions to any part of Loghi, be it the core toolkit or its various components, are highly appreciated. By working together, we can continue to develop and refine this powerful tool for handwritten text recognition.

## FAQ

Here are some frequently asked questions about Loghi and their answers to help you get started and troubleshoot common issues.

### Does Loghi work on Apple Silicon (M1/M2/M3)?

Currently, Loghi does not support utilizing Apple Silicon's accelerated hardware capabilities. We understand the importance and potential of supporting this architecture and are actively exploring possibilities to make Loghi compatible with Apple Silicon in the future. For now, users with Apple Silicon devices can run Loghi using emulation or virtualization tools, though this might not leverage the full performance capabilities of the hardware. We appreciate your patience and interest, and we're committed to broadening our hardware support to include these devices.

### How can I cite this software?

If you find this toolkit useful in your research, please cite:
```
@InProceedings{10.1007/978-3-031-70645-5_6,
author="van Koert, Rutger
and Klut, Stefan
and Koornstra, Tim
and Maas, Martijn
and Peters, Luke",
editor="Mouch{\`e}re, Harold
and Zhu, Anna",
title="Loghi: An End-to-End Framework for Making Historical Documents Machine-Readable",
booktitle="Document Analysis and Recognition -- ICDAR 2024 Workshops",
year="2024",
publisher="Springer Nature Switzerland",
address="Cham",
pages="73--88",
abstract="Loghi is a novel framework and suite of tools for the layout analysis and text recognition of historical documents. Scans are processed in a modular pipeline, with the option to use alternative tools in most stages. Layout analysis and text recognition can be trained on example images with PageXML ground truth. The framework is intended to convert scanned documents to machine-readable PageXML. Additional tooling is provided for the creation of synthetic ground truth. A visualiser for troubleshooting the text recognition training is also made available. The result is a framework for end-to-end text recognition, which works from initial layout analysis on the scanned documents, and includes text line detection, text recognition, reading order detection and language detection.",
isbn="978-3-031-70645-5"
}
