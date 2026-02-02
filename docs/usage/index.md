# Usage

```{toctree}
:maxdepth: 2

training
acceleration
webservice
gradio
```

<!-- add a section teaching the user to read the pagexml output? -->

## Using Loghi

<!-- below is content from the old docs/index.md. need to be distributed to child pages? -->

For detailed instructions on running inference, training new models, and other advanced features, refer to the [`scripts`](https://github.com/knaw-huc/loghi/tree/main/scripts) directory in this repository. There, you'll find sample scripts and a README designed to guide you through these processes efficiently:

- [`create-train-data.sh`](https://github.com/knaw-huc/loghi/blob/main/scripts/create-train-data.sh) for preparing training data for HTR models.
- [`generate-synthetic-images.sh`](https://github.com/knaw-huc/loghi/blob/main/scripts/generate-synthetic-images.sh) for generating synthetic text lines.
- [`htr-train-pipeline.sh`](https://github.com/knaw-huc/loghi/blob/main/scripts/htr-train-pipeline.sh) for training new HTR models.
- [`inference-pipeline.sh`](https://github.com/knaw-huc/loghi/blob/main/scripts/inference-pipeline.sh) for transcribing complete scans.

These scripts simplify the process of using Loghi for your HTR projects.

``` {tip}
> The [Loghi-HTR repository](https://github.com/knaw-huc/loghi-htr/) contains a config folder that provides a few quick-start configurations for running Loghi-HTR. These configurations can be used to quickly set up more advanced training and inference pipelines, allowing you to get started with Loghi-HTR in no time. Simply copy the desired config file, adjust the parameters as needed, and run Loghi-HTR using the `--config_file` parameter.
```

### Training using the HTR module 
#### Beginner / default
The default recommended way to train a new model is to use the `htr-train-pipeline.sh` script. This script will automatically download the latest version of the Loghi HTR module and train a new model using the specified training data.

#### Advanced: pseudolabels
Training using pseudo labels is a more advanced method that can be used to improve the performance of the model. This method uses a pre-trained model to generate pseudo labels for the training data, which can then be used to train a new model. This method is recommended for users who have lots of data that has no or limited ground truth for it.

To use this method, you will need to download a pre-trained model that seems to work nicely with your data and follow the steps for inferencing your data. After inferencing as much data as possible, you proceed with using the MinionCutFromImageBasedOnPageXMLNew to extract the text lines and transcriptions from your inferenced data. There is a flag `-minimum_confidence` which you can use to filter out the lines that are not confident enough. A suggested setting for minimum confidence is 0.5, but this can be adjusted based on your needs. 

An example script that runs the inference and creates pseudo labels would look like this:
```bash
#!/bin/bash
# Example script for running inference and creating pseudo labels
TODO: add contents
```

#### Synthetic data
It is possible to generate synthetic data with which a model can be trained. This is done by using the `generate-synthetic-images.sh` script. This script will generate synthetic text lines and save them in a specified directory. The generated images can then be used to train a new model.
This method is useful for users who want to create a large dataset quickly or for users who want to train a model on a specific font or style of handwriting. The generated images can be used in combination with real data to improve the performance of the model.


#### Advanced custom training
Training using custom datasets allows for more flexibility and can lead to better performance tailored to specific use cases. Users can define their own training parameters and configurations in the `htr-train-pipeline.sh` script. This method is suitable for advanced users who want to experiment with different training strategies and datasets.