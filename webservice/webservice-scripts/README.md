# Web Service Interaction Scripts

This README provides instructions on using a series of scripts designed to interact with a specific webservice for processing PageXML files and images. These scripts are examples illustrating a sequence of operations for handling and analyzing document images and their associated PageXML files.

## Prerequisites

Before running these scripts, ensure you have:
- Bash shell environment.
- `curl` installed on your system.
- Access to the webservice running at the specified localhost port.

## Workflow Steps

The scripts should be used in the following order to process your document images and PageXML files:

### 1. `do-laypa.sh`

- **Purpose**: Sends images to the webservice for layout analysis.
- **Usage**: `./do-laypa.sh <path_to_images>`
- **Input**: Directory path where your images are stored.

### 2. `extract-baselines.sh`

- **Purpose**: Extracts baselines from the images using the webservice.
- **Usage**: `./extract-baselines.sh <path_to_pagexml>`
- **Input**: Directory path where your PageXML files are stored, typically the output from the previous step.

### 3. `cut-from-image.sh`

- **Purpose**: Cuts text lines from the image based on PageXML data.
- **Usage**: `./cut-from-image.sh <path_to_images_and_pagexml>`
- **Input**: Directory path where your images and PageXML files are stored.

### 4. `do-htr.sh`

- **Purpose**: Performs Handwritten Text Recognition (HTR) on the text lines.
- **Usage**: `./do-htr.sh <path_to_line_images>`
- **Input**: Directory path where your line images are stored, the output from the previous step.

> [!IMPORTANT]
> After this HTR step, you need to concatenate all the individual line `group/id.txt` files for a group together to use as `result.txt` input in the next step.

### 5. `htr-merge-page-xml.sh`

- **Purpose**: Merges HTR results with the original PageXML.
- **Usage**: `./htr-merge-page-xml.sh <path_to_pagexml> <path_to_results> <path_to_htr_config>`
- **Input**: 
  - Path to the original PageXML file.
  - Path to the concatenated results file.
  - Path to the HTR configuration file.

### 6. `recalculate-reading-order.sh`

- **Purpose**: Recalculates the reading order in the PageXML.
- **Usage**: `./recalculate-reading-order.sh <path_to_pagexml>`
- **Input**: Directory path where your PageXML files are stored, typically the output from the previous step.

### 7. `split-into-words.sh`

- **Purpose**: Splits text lines into words within the PageXML.
- **Usage**: `./split-into-words.sh <path_to_pagexml>`
- **Input**: Directory path where your PageXML files to be split are stored.

## Additional Information

- These scripts are examples for illustrative purposes. Depending on your specific needs or the webservice configuration, modifications might be necessary.
- The setup of these scripts provides an easy-to-follow sequential workflow. In a production process, it is recommended to perform as many of these steps in parallel as possible to increase efficiency and throughput. Implementing parallel processing is more complex and requires careful management of dependencies and resources. 
- If you prefer to execute the entire workflow sequentially without the complexities of parallel processing, we recommend using the `inference-pipeline.sh` script located in the `scripts/` directory. This script automates the sequential execution of the workflow steps.
- Ensure that the webservice is running and accessible at the specified localhost port before executing these scripts.
- For detailed information about each script's functionality and options, refer to the comments within the scripts themselves.

