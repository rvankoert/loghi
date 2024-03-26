# Loghi Scripts

This directory contains scripts to facilitate the use of the Loghi toolkit for Handwritten Text Recognition (HTR). These scripts cover various aspects of the HTR workflow, including data preparation, training, and inference.

## Available Scripts

- `create-train-data.sh`: Utilized for generating training data from PageXML and corresponding images. This is a crucial first step in preparing your data for training a Loghi-HTR model.

- `generate-synthetic-images.sh`: For users interested in augmenting their training dataset, this script can create synthetic text lines. This is beneficial for improving the robustness of the Loghi-HTR model by providing a diverse set of training examples.

- `htr-train-pipeline.sh`: This script is designed for training or fine-tuning a Loghi-HTR model. It incorporates a comprehensive set of parameters to customize the training process according to your dataset's specific needs.

- `inference-pipeline.sh`: Aimed at executing the inference process, this script runs through the entire Loghi pipeline, including baseline detection, region detection, text line extraction, text prediction, merging results back into PageXML, recalculating reading order, detecting line language, and splitting text lines into words in the PageXML. Each of these steps can be enabled or disabled based on your requirements.

## Getting Started

### 1. Create Training Data

Before training your model, you need to create a dataset. The dataset must be organized in a specific manner for the `create-train-data.sh` script to process it correctly. Your input directory should look like this:

```
input
│  image1.png
│  image2.png
└─── page
    │  image1.xml
    │  image2.xml
```

This structure ensures that each image file has a corresponding PageXML file in a special `page` subdirectory. To generate a training dataset from this structured input, use the `create-train-data.sh` script as follows:

```bash
./create-train-data.sh /path/to/input/images /path/to/output/directory
```

This script processes images and their corresponding PageXML files to generate text files for the training dataset. The output text files will contain paths to snippet images and their corresponding textual representations, separated by a tab. For example, the output might look like this:

```
/path/to/training_data_folder/image1_snippets/snippet1.png    textual representation of snippet 1
/path/to/training_data_folder/image1_snippets/snippet2.png    text on snippet 2
```

This format is specifically designed for use in the Handwritten Text Recognition (HTR) process and can be utilized directly by the htr-train-pipeline.sh script.

The script will produce three output files:

- `training_all.txt`: Contains all text lines from the dataset.

- `training_all_train.txt`: Contains the subset of text lines designated for training.

- `training_all_val.txt`: Contains the subset of text lines designated for validation.

These files correspond to all the text lines, the lines used for training, and the lines used for validation, respectively.

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

After training your model, you can use it to transcribe new texts. If you haven't developed your own model yet or wish to test the pipeline with pre-trained models, our project provides access to pre-trained HTR and Laypa models.

You can download both the HTR model and the Laypa model from SurfDrive using the following link: [https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP](https://surfdrive.surf.nl/files/index.php/s/YA8HJuukIUKznSP). After downloading, ensure to edit the following inference pipeline script to point to the downloaded models.

To initiate the inference process with your model or the downloaded pre-trained models, execute the following command:

```bash
./inference-pipeline.sh /path/to/images
```

This command runs the entire Loghi pipeline, covering everything from detecting baselines, parsing the layout, predicting text, to updating the PageXML files. The output PageXML files will encompass the transcribed text, reading order, layout annotations, and other pertinent details.

The script is designed with flexibility in mind, offering high configurability. Each subpart of the process, such as baseline detection, layout parsing, or text prediction, can be individually enabled or disabled based on your specific requirements. This allows for a tailored inference process that can adapt to various datasets or research needs.

For detailed instructions on how to configure and run the inference pipeline, including how to integrate the pre-trained models and adjust the pipeline settings, please refer to the configuration section of this documentation or the dedicated configuration files provided within the project repository.
