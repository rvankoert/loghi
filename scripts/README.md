# Loghi Scripts

This directory contains scripts to facilitate the use of the Loghi toolkit for Handwritten Text Recognition (HTR). These scripts cover various aspects of the HTR workflow, including data preparation, training, and inference.

## Available Scripts

- `create-train-data.sh`: Utilized for generating training data from PageXML and corresponding images. This is a crucial first step in preparing your data for training a Loghi-HTR model.

- `generate-synthetic-images.sh`: For users interested in augmenting their training dataset, this script can create synthetic text lines. This is beneficial for improving the robustness of the Loghi-HTR model by providing a diverse set of training examples.

- `htr-train-pipeline.sh`: This script is designed for training or fine-tuning a Loghi-HTR model. It incorporates a comprehensive set of parameters to customize the training process according to your dataset's specific needs.

- `inference-pipeline.sh`: Aimed at executing the inference process, this script runs through the entire Loghi pipeline, including baseline detection, region detection, text line extraction, text prediction, merging results back into PageXML, recalculating reading order, detecting line language, and splitting text lines into words in the PageXML. Each of these steps can be enabled or disabled based on your requirements.

## Getting Started

### 1. Create Training Data

Before training your model, you need to create a dataset. Use the `create-train-data.sh` script as follows:

```bash
./create-train-data.sh /path/to/input/images /path/to/output/directory
```

This script processes images and their corresponding PageXML files to generate a training dataset.

### 2. Generate Synthetic Images (Optional)

To enhance your training dataset, you might consider generating synthetic text lines:

```bash
./generate-synthetic-images.sh /path/to/fonts/ /path/to/texts/
```

### 3. Train or Fine-Tune a Loghi-HTR Model

This section provides detailed guidance on how to train or fine-tune a Loghi-HTR model using the `htr-train-pipeline.sh` script. This script is designed with flexibility in mind, offering numerous configurable parameters to tailor the training process to your specific requirements.

#### Getting Started with a Baseline Model

If you're new to training Loghi-HTR models or wish to fine-tune an existing model, it's recommended to start with a baseline HTR model. A suitable baseline model can be downloaded from [SurfDrive](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP).

These models serve as a solid foundation for fine-tuning on your specific dataset, especially if it's similar in nature to the data the baseline model was trained on.

#### Configuring the Training Process

The `htr-train-pipeline.sh` script contains several parameters that you can adjust to configure the training process. These include settings for the training data, validation set, learning rate, number of epochs, and much more. While the script includes sane defaults, fine-tuning these parameters can significantly impact the performance of the trained model.

For those looking to deeply customize their training process, it's highly recommended to explore the `loghi-htr` [GitHub repository](https://github.com/knaw-huc/loghi-htr).

This repository contains extensive documentation on the training configurations, offering insights into advanced training techniques, optimization strategies, and how to best utilize the Loghi-HTR framework for your handwritten text recognition tasks.

#### Training a Model

With your training data ready, you can begin training a new model or fine-tune an existing one:

```bash
./htr-train-pipeline.sh
```

Be sure to adjust the script parameters to suit your specific training setup.

### 4. Run Inference

After training your model, you can use it to transcribe new texts:

```bash
./inference-pipeline.sh /path/to/images
```

This script runs the entire Loghi pipeline, from detecting baselines to predicting text and updating the PageXML files. The resulting PageXML files will contain the transcribed text, reading order, and other relevant information.

This script is also highly configurable and each subpart of the process can be enabled or disabled based on your requirements.
