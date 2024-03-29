# Loghi Web Service

This guide provides instructions for deploying and using the Loghi framework in a dockerized environment, utilizing APIs for a seamless workflow in handwritten text recognition and layout analysis.

## Environment Setup

The deployment uses Docker and Docker Compose, simplifying the setup and eliminating concerns about local environment variations. This README is located in the `webservice` directory, containing all you need to get started.

### Directory Overview

- `loghi-tooling/`: Contains `configuration.yml` for tooling configuration.
- `webservice-scripts/`: Includes example scripts for each part of the pipeline, designed to demonstrate how to integrate and automate various Loghi components.
- `docker-compose.yml`: An example Docker Compose file to orchestrate the startup of all web services (tooling, HTR, and Laypa) with a simple `docker compose up` command.

## Getting Started

### Starting the Services

To initialize the Loghi web services:

1. Ensure Docker and Docker Compose are installed on your system.

2. Start the Docker containers with the following command:

    ```bash
    docker compose up
    ```

   This boots up the necessary Docker containers and provides a log of the operations. Ensure you have Docker Compose version `1.28.0` or higher for proper GPU support, if required. 

### Processing Workflow

The Loghi framework provides a flexible pipeline for processing handwritten texts. Here is a generalized workflow to guide your usage:

1. **Baseline Detection:** Use Laypa to identify text baselines and regions in your documents, preparing them for HTR.

2. **Image Preprocessing:** If needed, preprocess images to enhance text recognition accuracy, such as line extraction and image normalization.

3. **Handwritten Text Recognition (HTR):** Process the prepared images through Loghi HTR to transcribe the text.

4. **Post-processing:** Apply necessary post-processing steps, such as merging HTR results into PageXML format, recalculating reading order, and splitting text into words.

5. **Integration and Automation:** Utilize the `webservice-scripts/` as templates to automate the workflow and integrate Loghi components into your system. For more information on the available scripts, refer to the `webservice-scripts/README.md` file.

## Note

- The web service setup provided here is adaptable and can be customized to fit specific project requirements.
- Ensure your Docker environment is properly configured, especially when leveraging GPU acceleration for processing tasks.

The flexibility and modularity of Loghi allow it to be tailored to a wide range of document analysis and text recognition projects, providing robust tools for researchers and developers alike.

