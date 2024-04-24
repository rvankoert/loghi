# Loghi: Handwritten Text Recognition Toolkit

Loghi is a comprehensive toolkit designed for Handwritten Text Recognition (HTR) and Optical Character Recognition (OCR), offering an accessible approach to transcribing historical documents and training models for specialized needs. This README provides a quick start guide for using Loghi, including how to install, run inference, train new models, and utilize our scripts for these tasks.

## Table of Contents
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
- [Gradio Demo](#gradio-demo)
- [Contributing](#contributing)
- [FAQ](#faq)

## Introduction to Loghi

The Loghi framework is designed to streamline the process of Handwritten Text Recognition (HTR), from analyzing document layouts to transcribing handwritten text into digital format. At the core of Loghi are three critical components, each responsible for a distinct aspect of the HTR pipeline:

### Laypa: Layout Analysis and Segmentation

Laypa specializes in the segmentation of documents, identifying different regions like paragraphs, page numbers, and most importantly, baselines within the text. Utilizing a sophisticated architecture based on a ResNet backbone and a feature pyramid network, Laypa performs pixel-wise classifications to detect these elements. Built on the [detectron2](https://github.com/facebookresearch/detectron2) framework, its output facilitates further processing by converting the classifications into instances—either as masks or directly into PageXML format. This segmentation is crucial for preparing documents for OCR/HTR processing, ensuring that text regions are accurately recognized and extracted.

### Loghi Tooling: Pre and Post-Processing Toolkit

The Loghi Tooling module offers a suite of utilities designed to support the Loghi framework, handling tasks that occur both between and following the machine learning stages. This includes cutting images into individual text lines, integrating the transcription results into the PageXML, and recalculating reading orders among others. Its role is vital in managing the workflow of document preparation and finalization, streamlining the transition from raw image to processed text.

### Loghi HTR: Text Transcription

At the heart of the Loghi framework, the Loghi HTR module is responsible for the actual transcription of text from images. This system is not limited to handwritten text, as it is also capable of processing machine-printed text. By converting line images into textual data, Loghi HTR forms the final step in the HTR process, bridging the gap between visual data and usable digital text.

Together, these components form a comprehensive ecosystem for handling HTR tasks, from initial layout analysis to the final transcription of text. The Loghi framework offers a modular approach, allowing users to engage with individual components based on their specific needs, while also providing a cohesive solution for end-to-end handwritten text recognition.

## Quick Start

### Installation

Begin by cloning the Loghi repository to access the toolkit and navigate into the directory:

```bash
git clone git@github.com:knaw-huc/loghi.git
cd loghi
```

### Docker Images

For most users, Docker offers the easiest and most straightforward way to deploy and use Loghi. Pre-built Docker images contain all the necessary dependencies and can be easily pulled from [Docker Hub](https://hub.docker.com/u/loghi):

```bash
docker pull loghi/docker.laypa
docker pull loghi/docker.htr
docker pull loghi/docker.loghi-tooling
```

If Docker is not installed on your machine, follow [these instructions](https://docs.docker.com/engine/install/) to install it.

Alternatively, to build the Docker images with the latest code yourself:

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

For detailed instructions on running inference, training new models, and other advanced features, refer to the `scripts` directory in this repository. There, you'll find sample scripts and a README designed to guide you through these processes efficiently:

- `create-train-data.sh` for preparing training data for HTR models.
- `generate-synthetic-images.sh` for generating synthetic text lines.
- `htr-train-pipeline.sh` for training new HTR models.
- `inference-pipeline.sh` for transcribing complete scans.

These scripts simplify the process of using Loghi for your HTR projects.

> [!TIP]
> The [Loghi-HTR repository](https://github.com/knaw-huc/loghi-htr/) contains a config folder that provides a few quick-start configurations for running Loghi-HTR. These configurations can be used to quickly set up more advanced training and inference pipelines, allowing you to get started with Loghi-HTR in no time. Simply copy the desired config file, adjust the parameters as needed, and run Loghi-HTR using the `--config_file` parameter.

## Running the Web Service

The `webservice` directory contains a README with instructions on how to get started with running the Loghi web service for online transcription tasks. This setup is designed to provide an accessible way to engage with the service, catering both to those new to the platform and to seasoned users looking for advanced functionalities.

Within the `webservice` directory, you'll find a subdirectory named `scripts` that includes detailed instructions and scripts for utilizing the entire transcription pipeline. These scripts are designed to demonstrate the workflow from start to finish, providing a hands-on approach to understanding and implementing the transcription process.

For further customization and in-depth information, please refer to the original repositories linked within our toolkit. These resources offer comprehensive documentation on adjusting parameters, understanding the technology behind Loghi, and exploring advanced use cases. Whether you're looking to fine-tune the service to your specific needs or dive into the technicalities of transcription technologies, these repositories are invaluable resources.

## Updates

To stay updated with the latest versions of the submodules, run:

```bash
git submodule update --recursive --remote
```

This ensures you have access to the most recent (though possibly unstable) versions of the code.

## Gradio Demo

Explore the capabilities of Loghi Software with our interactive Gradio demo. The demo provides a user-friendly graphical interface, allowing you to upload document images, perform layout analysis, and view Handwritten Text Recognition (HTR) results in real-time.

For detailed instructions on how to set up and use the demo, visit the [Gradio directory](gradio/README.md) and follow the README provided there.

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

