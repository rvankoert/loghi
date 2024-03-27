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
- [Using Loghi](#using-loghi)
- [Running the Web Service](#running-the-web-service)
- [Contributing](#contributing)
- [FAQ](#faq)

## Introduction to Loghi

The Loghi framework is designed to streamline the process of Handwritten Text Recognition (HTR), from analyzing document layouts to transcribing handwritten text into digital format. At the core of Loghi are three critical components, each responsible for a distinct aspect of the HTR pipeline:

### Laypa: Layout Analysis and Segmentation

Laypa specializes in the segmentation of documents, identifying different regions like paragraphs, page numbers, and most importantly, baselines within the text. Utilizing a sophisticated architecture based on a ResNet backbone and a feature pyramid network, Laypa performs pixel-wise classifications to detect these elements. Built on the detectron2 framework, its output facilitates further processing by converting the classifications into instances—either as masks or directly into PageXML format. This segmentation is crucial for preparing documents for OCR/HTR processing, ensuring that text regions are accurately recognized and extracted.

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

## Using Loghi

For detailed instructions on running inference, training new models, and other advanced features, refer to the `scripts` directory in this repository. There, you'll find sample scripts and a README designed to guide you through these processes efficiently:

- `create-train-data.sh` for preparing training data for HTR models.
- `generate-synthetic-images.sh` for generating synthetic text lines.
- `htr-train-pipeline.sh` for training new HTR models.
- `inference-pipeline.sh` for transcribing complete scans.

These scripts simplify the process of using Loghi for your HTR projects.

## Running the Web Service

(TODO: This section will be updated with instructions on how to set up and run the Loghi web service for online transcription tasks.)

For further customization and in-depth information, please refer to the original repositories linked within our toolkit. These resources provide comprehensive documentation on adjusting parameters, understanding the technology behind Loghi, and exploring advanced use cases.

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

