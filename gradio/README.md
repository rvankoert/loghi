# Loghi Software Gradio Demo

This directory contains the Gradio demo for Loghi Software. It features a graphical user interface (GUI) to demonstrate the capabilities of Loghi tools including Loghi Tooling, Laypa, and Loghi-HTR. 

> [!NOTE]
> This is a demonstration setup and is not optimized for batch processing or high-workload production environments.

## Features

- Interactive GUI for process visualization and result inspection.
- Recommended Docker setup for ease of configuration.

## Prerequisites

Before you begin, ensure you have the necessary tools installed:

- **Docker**: Required if you opt for the recommended Docker setup.
- **Python and pip**: Necessary for running the demo using Python.

## Setup and Running the Demo

### Recommended: Docker Setup

1. Build the Docker image using the following command:

   ```bash
   docker build -t loghi-demo .`
   ```

2. Navigate to the `docker` directory:

   ```bash
   cd docker
   ```

3. Configure the variables in the `.env` file to suit your setup.
3. To run the demo, execute:

   ```bash
   docker-compose up
   ```

   This starts all necessary services including the Gradio server.

### Alternative: Python Setup

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

   ![Start Screen with Uploaded Image](path/to/screenshot1.png)

2. **Laypa Result**: After processing, the demo shows the Laypa results, displaying the layout analysis of the uploaded document. It segments the document into lines, facilitating further processing.

   ![Laypa Result](path/to/screenshot2.png)

3. **HTR Result**: The Handwritten Text Recognition (HTR) result screen showcases the extracted text from the document. This screen validates the accuracy and quality of the text recognition process.

   ![HTR Result](path/to/screenshot3.png)

4. **PageXML Output**: The demo allows users to download the PageXML file, which contains detailed annotations of the text and its structure as recognized by the tool. This file can be used for a variety of downstream tasks and applications.

   ![PageXML Output](path/to/screenshot4.png)

