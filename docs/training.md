# Training and finetuning Laypa and Loghi models

## Laypa
The Laypa training pipeline (scripts/laypa-train-pipeline.sh) is designed to train or fine-tune a Laypa model using Docker. Key steps include:




## Loghi HTR Training Pipeline
The training pipeline (scripts/htr-train-pipeline.sh) is used to train or fine-tune a Handwritten Text Recognition (HTR) model using Docker. Key steps include:


### Configuration: 
Set parameters for model type, GPU usage, dataset paths, training epochs, batch size, and learning rate.
### Model Selection:
Choose to train a new model or fine-tune an existing one. Optionally replace the final layer for character set adaptation.
### Docker Execution: 
Launches a Docker container with the specified resources and mounts, running the training script with all configured options.
### Output: 
Results and trained models are saved to a temporary or user-defined output directory.


## Loghi Inference Pipeline


The inference pipeline (scripts/inference-pipeline.sh) processes images to extract text using trained models. Main steps:


Configuration: Set options for baseline/region detection, HTR model path, reading order recalculation, language detection, and GPU usage.
Laypa Baseline/Region Detection: Optionally runs Laypa models for baseline and region detection on input images.
Baseline Extraction: Extracts baselines and regions using Loghi tooling.
Snippet Extraction: Cuts out line snippets from images for HTR processing.
HTR Inference: Runs the HTR model on snippets to recognize text.
Result Merging: Merges recognized text back into PageXML files.
Post-processing: Optionally recalculates reading order, detects language, and splits text lines into words.
Cleanup: Removes temporary files after processing.
Both pipelines are designed to be run via Bash scripts and leverage Docker containers for reproducibility and resource management.