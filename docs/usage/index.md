# Usage

```{toctree}
:maxdepth: 2

training
acceleration
webservice
gradio
understanding-output
```

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

