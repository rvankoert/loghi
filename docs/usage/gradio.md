# Gradio Demo

:::{note}
The contents of this page are under review.
:::

The Gradio Demo features an interactive graphical user interface (GUI) for process visualization and result inspection, demonstrating the capabilities of Loghi tools including Loghi Tooling, Laypa, and Loghi-HTR. 

:::{note}
1. This is a demonstration setup and is not optimized for batch processing or high-workload production environments.
2. The Gradio demo accepts image files only (`.jpg`, `.jpeg`, `.png`, `.tiff`, `.bmp`, etc.). PDF files are not supported. 
:::

## Prerequisites

Before starting, ensure you have:
- Cloned the Loghi repository (see [Installation: Clone the Repository](clone-repo))
- Installed Docker (see [Installation: Install Docker](install-docker))
- Installed Docker Compose (usually included with Docker; verify with `docker compose version`)
- Downloaded Loghi models (see [Installation: Download Models](download-models))
- Installed Python and pip (**optional**, only if you opt for the Python setup)

## Setup and Running the Demo

:::::{tab-set}

::::{tab-item} Recommended: Docker Setup

1. Navigate to the `gradio` directory from your cloned Loghi repository:

   ```bash
   cd gradio
   ```

2. Build the Docker image:

   ```bash
   docker build -t loghi-demo .
   ```

3. Navigate to the `docker` subdirectory under the `gradio` directory:

   ```bash
   cd docker
   ```

4. Open the `.env` file in a text editor and update the following variables:
   
   **Required changes**:
   - `LAYPA_MODEL_PATH`: Full path to your downloaded Laypa model directory (e.g., `/home/downloads/laypa-models/general/baseline`)
   - `LOGHI_BASE_MODEL_DIR`: Full path to the parent directory containing your HTR model(s) (e.g., `/home/downloads/loghi-htr-models`)
   - `LOGHI_MODEL_NAME`: Name of the specific HTR model folder inside `LOGHI_BASE_MODEL_DIR` (e.g., `float32-generic-2023-02-15`)
   - `TOOLING_CONFIG_FILE`: Full path to `configuration.yml` in your cloned repository (e.g., `/home/loghi/webservice/loghi-tooling/configuration.yml`)
   - `LAYPA_OUTPUT_PATH`, `LOGHI_OUTPUT_PATH`, and `TOOLING_OUTPUT_PATH`: Directories where output files will be saved. These directories must exist before running the container, otherwise you will get permission errors. Use `/tmp` paths for the simplest setup (e.g., `/tmp/loghi/laypa`, `/tmp/loghi/htr`, `/tmp/loghi/tooling`).

   **Optional changes**:
   - `MY_UID` and `MY_GID`: User and group IDs for file ownership. Default is `1000`, which is the standard first user on most Linux systems. Run `id -u` and `id -g` to check yours.
   - GPU configuration:
     - Keep both `LAYPA_GPU_COUNT` and `HTR_GPU_COUNT` at `0` for CPU mode, or
     - Leave `LAYPA_GPU_COUNT` at `0` and set `HTR_GPU_COUNT` to `1` if you have a single GPU, or
     - Set both `LAYPA_GPU_COUNT` and `HTR_GPU_COUNT` to `1` if you have multiple GPUs
   - `GRADIO_QUEUE_SIZE`: Maximum number of queued requests (default: `10`)
   - `GRADIO_WORKERS`: Number of concurrent workers (default: `1`)

5. Save the changes in the `.env` file, then run the demo:

   ```bash
   docker compose up
   ```

   This starts all necessary services including the Gradio server.

:::{note}
If your system uses legacy Compose v1, run `docker-compose up` instead.
:::

::::

::::{tab-item} Alternative: Python Setup

1. Navigate to the `gradio` directory and install the required Python dependencies:

   ```bash
   cd gradio
   pip install -r requirements.txt
   ```
   
2. Navigate back to the main Loghi directory to build and start the required services (Laypa, HTR, and Loghi Tooling) individually:
   
   **2.1 Build Docker images:**
   ```bash
   cd ..
   # Build Laypa image
   ./docker/docker.laypa/buildImage.sh ./laypa
   
   # Build HTR image
   ./docker/docker.htr/buildImage.sh ./loghi-htr
   
   # Build Loghi Tooling image
   ./docker/docker.loghi-tooling/buildImage.sh ./prima-core-libs ./loghi-tooling 1.0.0
   ```
   
   **2.2 Create output directories:**
   ```bash
   mkdir -p /tmp/loghi/laypa /tmp/loghi/htr /tmp/loghi/tooling
   ```
   
   :::{note}
   Using `/tmp` is the simplest option. These directories are cleared on reboot, so copy any results you want to keep. If you prefer persistent storage, use a directory elsewhere (e.g., `~/loghi-output/`) but make sure the permissions allow Docker containers to write to it.
   :::
   
   **2.3 Start the services:**
   
   Replace all placeholder paths with your actual model and configuration locations before running these commands.
   
   **Laypa service:**
   ```bash
   docker run -d --name laypa -p 5000:5000 --shm-size 512mb \
     --user $(id -u):$(id -g) \
     -e LAYPA_MODEL_BASE_PATH=/path/to/your/laypa/model/ \
     -e LAYPA_OUTPUT_BASE_PATH=/output \
     -e LAYPA_MAX_QUEUE_SIZE=128 \
     -e LAYPA_LEDGER_SIZE=1000000 \
     -e GUNICORN_RUN_HOST=0.0.0.0:5000 \
     -e GUNICORN_WORKERS=1 \
     -e GUNICORN_THREADS=1 \
     -e GUNICORN_ACCESSLOG=- \
     -v /path/to/your/laypa/model/:/path/to/your/laypa/model/ \
     -v /tmp/loghi/laypa:/output \
     loghi/docker.laypa python api/gunicorn_app.py
   ```
   
   **HTR service:**
   ```bash
   docker run -d --name htr -p 5001:5000 --shm-size 512mb \
     --user $(id -u):$(id -g) \
     -e LOGHI_BASE_MODEL_DIR=/path/to/your/htr/models/directory/ \
     -e LOGHI_MODEL_NAME=your-model-folder-name \
     -e LOGHI_OUTPUT_PATH=/output \
     -e LOGHI_BATCH_SIZE=64 \
     -e LOGHI_MAX_QUEUE_SIZE=50000 \
     -e LOGHI_PATIENCE=0.5 \
     -v /path/to/your/htr/models/directory/:/path/to/your/htr/models/directory/ \
     -v /tmp/loghi/htr:/output \
     loghi/docker.htr \
     sh -c 'cd api && uvicorn app:app --host 0.0.0.0 --port 5000'
   ```
   
   **Loghi Tooling service:**
   ```bash
   docker run -d --name loghi-tooling -p 8080:8080 -p 8081:8081 --shm-size 512mb \
     --user $(id -u):$(id -g) \
     -e STORAGE_LOCATION=/output \
     -v /path/to/loghi/webservice/loghi-tooling/configuration.yml:/config/configuration.yml \
     -v /tmp/loghi/tooling:/output \
     loghi/docker.loghi-tooling \
     /src/loghi-tooling/loghiwebservice/target/appassembler/bin/LoghiWebserviceApplication \
     server /config/configuration.yml
   ```
   
   :::{important}
   **Required path replacements:**
   - `/path/to/your/laypa/model/`: Full path to your Laypa model directory (must match in both `-e` and `-v`)
   - `/path/to/your/htr/models/directory/`: Full path to the parent directory containing your HTR model(s) (must match in both `-e` and `-v`)
   - `your-model-folder-name`: The folder name of your HTR model inside the above directory (e.g., `generic-2023-02-15`)
   - `/path/to/loghi/webservice/loghi-tooling/configuration.yml`: Full path to `configuration.yml` in your cloned repository
   
   **Note:** The HTR model must include a `config.json` file. If your model is missing this file, the service will not work properly.
   
   **For GPU support:** Add `--gpus all` after `docker run` in the Laypa and HTR commands and remove the `--user` flag.
   
   :::

3. Configure environment variables for the Gradio interface:

   Open `gradio/start_with_python.sh` in a text editor and update the placeholder values:
   ```bash
   export LAYPA_MODEL_PATH=/path/to/your/laypa/model/
   export LAYPA_OUTPUT_PATH=/tmp/loghi/laypa
   export LAYPA_LEDGER_SIZE=1000000
   export LOGHI_MODEL_BASE_DIR=/path/to/your/htr/models/directory/
   export LOGHI_MODEL_NAME=your-model-folder-name
   export LOGHI_OUTPUT_PATH=/tmp/loghi/htr
   export TOOLING_OUTPUT_PATH=/tmp/loghi/tooling
   ```
   
   :::{important}
   - `LAYPA_MODEL_PATH`: Must match the path you used in the Laypa docker run command
   - `LOGHI_MODEL_BASE_DIR` + `LOGHI_MODEL_NAME`: Together they form the full HTR model path (must match the HTR docker run command)
   - All output paths must match the corresponding `-v` mount targets in the Docker containers
   :::

4. Launch the Gradio demo interface:

   ```bash
   cd gradio
   ./start_with_python.sh
   ```
::::

:::::

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

:::::{tab-set}

::::{tab-item} Docker Setup

To stop the demo:

```bash
docker compose down
```
::::

::::{tab-item} Python Setup

1. Stop the Gradio interface: press `Ctrl+C` in the terminal, where `start_with_python.sh` is running.

2. Stop the Docker containers:
   ```bash
   docker stop laypa htr loghi-tooling
   ```

3. Remove the containers (optional, only if you want to clean up completely):
   ```bash
   docker rm laypa htr loghi-tooling
   ```
   
   :::{note}
   If you skip step 3, you can restart the stopped containers later with `docker start laypa htr loghi-tooling` without having to rebuild them.
   :::
::::

:::::