# Gradio Demo

<!-- content pasted from readme.md in gradio, now being updated -->

The Gradio Demo features an interactive graphical user interface (GUI) for process visualization and result inspection, demonstrating the capabilities of Loghi tools including Loghi Tooling, Laypa, and Loghi-HTR. 

:::{note}
This is a demonstration setup and is not optimized for batch processing or high-workload production environments.
:::

## Prerequisites

Before you begin, ensure you have the necessary tools installed:

- **Docker**: Required if you opt for the recommended Docker setup.
- **Python and pip**: Necessary for running the demo using Python.

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
   
2. Start each necessary service component:
   
   Since the services cannot be started with a single command, you'll need to either:
   - Start each Docker container individually, ensuring they run in webservice mode, or
   - Navigate to each submodule repository and follow the specific instructions provided there to start each service.


3. To launch the Gradio demo interface:

   ```bash
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

1. **Start Screen with Uploaded Image**: This is the initial screen where users can upload a document image to process. It’s the starting point of the demo where you begin your interaction with the Loghi tools.

   ![Start Screen with Uploaded Image](https://github.com/rvankoert/loghi/assets/89044870/d343dae8-ca74-4e25-b438-05f3d1fbcb6d)

2. **Laypa Result**: After processing, the demo shows the Laypa results, displaying the layout analysis of the uploaded document. It segments the document into lines, facilitating further processing.

   ![Laypa Result](https://github.com/rvankoert/loghi/assets/89044870/1a8662d4-2c78-4df4-b48e-adb0e9df1905)

3. **HTR Result**: The Handwritten Text Recognition (HTR) result screen showcases the extracted text from the document. This screen validates the accuracy and quality of the text recognition process.

   ![HTR Result](https://github.com/rvankoert/loghi/assets/89044870/7d0dd0eb-d2ac-4504-b9e1-77cf437483f7)

4. **PageXML Output**: The demo allows users to download the PageXML file, which contains detailed annotations of the text and its structure as recognized by the tool. This file can be used for a variety of downstream tasks and applications.

   ![PageXML Output](https://github.com/rvankoert/loghi/assets/89044870/b2bb96a2-d19d-41d7-995d-a738e7640c56)

