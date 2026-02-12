# Gradio Demo

<!-- content partly pasted from readme.md in gradio and partly created by claude, now being updated -->

The Gradio Demo features an interactive graphical user interface (GUI) for process visualization and result inspection, demonstrating the capabilities of Loghi tools including Loghi Tooling, Laypa, and Loghi-HTR. 

:::{note}
This is a demonstration setup and is not optimized for batch processing or high-workload production environments.
:::

## Prerequisites

Before starting, ensure you have:
- Cloned the Loghi repository (see [Installation](../installation/installation.md#1-clone-the-repository))
- Installed Docker and Docker Compose (see [Installation](../installation/installation.md#2-install-docker))
- Downloaded Loghi models (see [Installation](../installation/installation.md#5-download-models))
- Installed Python and pip (optional, only if you opt for the Python setup)

## Setup and Running the Demo

::::{tab-set}

:::{tab-item} Recommended: Docker Setup

1. Navigate to the `gradio` directory from your cloned Loghi repository:

   ```bash
   cd gradio
   ```

2. Build the Docker image:

   ```bash
   docker build -t loghi-demo .
   ```

3. Navigate to the `docker` subdirectory:

   ```bash
   cd docker
   ```

4. Open the `.env` file in a text editor and update these paths to match your system:
   
   - `LAYPA_MODEL_PATH`: Full path to your Laypa model directory (e.g., `/home/yourname/Downloads/laypa-models/general/baseline`)
   - `LOGHI_BASE_MODEL_DIR`: Full path to the directory containing your HTR models (e.g., `/home/yourname/Downloads/loghi-models`)
   - `LOGHI_MODEL_NAME`: Name of the specific HTR model to use (the folder name inside `LOGHI_BASE_MODEL_DIR`)
   - `TOOLING_CONFIG_FILE`: Full path to `loghi/webservice/loghi-tooling/configuration.yml` in your cloned repository
   
   You may also want to:
   - Change `LAYPA_OUTPUT_PATH`, `LOGHI_OUTPUT_PATH`, and `TOOLING_OUTPUT_PATH` to where you want output files saved (directories must exist)
   - Set `LAYPA_GPU_COUNT` and `HTR_GPU_COUNT` to `1` if you have GPU support (keep at `0` for CPU mode)

5. Run the demo:

   ```bash
   docker-compose up
   ```

   This starts all necessary services including the Gradio server.
:::

:::{tab-item} Alternative: Python Setup

1. Install the required Python dependencies:

   ```bash
   pip install -r requirements.txt
   ```
   
2. Start the required services (Laypa, HTR, and Loghi Tooling) individually:
   
   **Build and run Laypa service:**
   ```bash
   # Navigate to the relevant folder and build the Docker image using the provided script
   cd docker/docker.laypa
   ./buildImage.sh ../../laypa
   
   # Run the container
   docker run -d \
     --name laypa-service \
     -p 5000:5000 \
     -v /path/to/your/laypa/model:/models \
     -e LAYPA_MODEL_BASE_PATH=/models \
     -e LAYPA_LEDGER_SIZE=1024 \
     loghi/docker.laypa
   ```
   
   **Build and run HTR service:**
   ```bash
   # Navigate to the relevant folder and build the Docker image using the provided script
   cd ../docker.htr
   ./buildImage.sh ../../loghi-htr
   
   # Run the container
   docker run -d \
     --name htr-service \
     -p 5001:5001 \
     -v /path/to/your/htr/model:/models \
     -e LOGHI_MODEL_PATH=/models \
     loghi/docker.htr
   ```
   
   **Build and run Loghi Tooling service:**
   ```bash
   # Navigate to the relevant folder and build the Docker image using the provided script
   cd ../docker.loghi-tooling
   ./buildImage.sh ../../prima-core-libs ../../loghi-tooling 1.0.0
   
   # Run the container
   docker run -d \
     --name tooling-service \
     -p 8080:8080 \
     -v /path/to/configuration.yml:/app/config.yml \
     loghi/docker.loghi-tooling
   ```
   
   :::{important}
   Replace `/path/to/your/laypa/model` and `/path/to/your/htr/model` with your actual local paths to the model directories.
   
   Replace `/path/to/configuration.yml` with the full path to the `configuration.yml` file in your cloned Loghi repository's `webservice/loghi-tooling/` directory.
   
   The paths on the left side of `:` are your local machine paths. The paths on the right side are inside the container and should not be changed.
   :::

3. Launch the Gradio demo interface:

   ```bash
   cd ../../gradio
   ./start_with_python.sh
   ```
:::

::::

## Using the Demo

After you've set up the demo using Docker or Python, here's how you can proceed with using it:

1. Navigate to the Gradio web interface at `http://localhost:7860`.
2. Upload a document image to start the processing.
3. View the Laypa results to see the layout analysis.
4. Check the HTR results for the extracted text.
5. Download the PageXML output for detailed text annotations.

## Screenshots and Workflow

The following screenshots provide a visual overview of the Gradio interface and the workflow for the Loghi Software demo:

1. **Start Screen with Uploaded Image**: This is the initial screen where users can upload a document image to process. It's the starting point of the demo where you begin your interaction with the Loghi tools.

   ![Start Screen with Uploaded Image](https://github.com/rvankoert/loghi/assets/89044870/d343dae8-ca74-4e25-b438-05f3d1fbcb6d)

2. **Laypa Result**: After processing, the demo shows the Laypa results, displaying the layout analysis of the uploaded document. It segments the document into lines, facilitating further processing.

   ![Laypa Result](https://github.com/rvankoert/loghi/assets/89044870/1a8662d4-2c78-4df4-b48e-adb0e9df1905)

3. **HTR Result**: The Handwritten Text Recognition (HTR) result screen showcases the extracted text from the document. This screen validates the accuracy and quality of the text recognition process.

   ![HTR Result](https://github.com/rvankoert/loghi/assets/89044870/7d0dd0eb-d2ac-4504-b9e1-77cf437483f7)

4. **PageXML Output**: The demo allows users to download the PageXML file, which contains detailed annotations of the text and its structure as recognized by the tool. This file can be used for a variety of downstream tasks and applications.

   ![PageXML Output](https://github.com/rvankoert/loghi/assets/89044870/b2bb96a2-d19d-41d7-995d-a738e7640c56)


## Stopping the Demo
<!-- to be verified, check the paths-->

::::{tab-set}

:::{tab-item} Docker Setup

To stop the demo and all services:

```bash
docker-compose down
```

This will stop and remove all containers started by the Docker setup.
:::

:::{tab-item} Python Setup

1. **Stop the Gradio interface**: Press `Ctrl+C` in the terminal where `start_with_python.sh` is running

2. **Stop the Docker containers**:
   ```bash
   docker stop laypa-service htr-service tooling-service
   ```

3. **Remove the containers** (optional, only if you want to clean up completely):
   ```bash
   docker rm laypa-service htr-service tooling-service
   ```
   
   :::{note}
   If you skip step 3, you can restart the stopped containers later with `docker start laypa-service htr-service tooling-service` without having to rebuild them.
   :::
:::

::::