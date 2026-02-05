# Loghi Web Service

<!-- content being updated -->

This page contains information on how to get started with running the Loghi web service for online transcription tasks, which provide an accessible way to engage with the service, catering both to those new to the platform and to seasoned users looking for advanced functionalities.

## Directory Overview

Here's an overview of the [`webservice/` directory](https://github.com/knaw-huc/loghi/tree/main/webservice). 

- `loghi-tooling/`: Contains `configuration.yml` for tooling configuration.
- `webservice-scripts/`: Includes example scripts for each part of the [pipeline](../introduction.md/#how-loghi-works), designed to demonstrate how to integrate and automate various Loghi components. 
- `docker-compose.yml`: An example Docker Compose file to orchestrate the startup of all web services (tooling, HTR, and Laypa) with a simple `docker compose up` command.


## Getting Started

### 1. Prepare the environment

The deployment uses Docker and Docker Compose, simplifying the setup and eliminating concerns about local environment variations. First ensure Docker and Docker Compose are installed on your system:
```bash
docker --version          # Check Docker version
docker-compose --version  # Check Docker Compose version
```

If you want to use GPU acceleration, ensure you have Docker Compose version 1.28.0 or higher.

### 2. Navigate to the webservice directory

```bash
cd webservice
```

### 3. Configure the services

Before starting the services, you need to configure the model paths and output locations in `docker-compose.yml`:

1. Open `docker-compose.yml` in a text editor
2. Update the environment variables to point to your model locations:
   - `LAYPA_MODEL_BASE_PATH`: Path to your Laypa model
   - `LOGHI_MODEL_PATH`: Path to your Loghi HTR model
   - `LAYPA_OUTPUT_BASE_PATH`: Where Laypa should save output
   - `LOGHI_OUTPUT_PATH`: Where HTR should save output

3. Update the volume mounts to match your system paths

:::{tip}
You can use environment variables to override these settings without editing the file:
```bash
export LAYPA_MODEL_BASE_PATH=/path/to/your/laypa/model
export LOGHI_MODEL_PATH=/path/to/your/htr/model
```
:::

### 4. Start the services

Start the Docker containers:

```bash
docker compose up
```

This boots up the necessary Docker containers and provides a log of the operations. The services will be available at:
- **Laypa (Layout Analysis):** `http://localhost:5000`
- **Loghi HTR (Text Recognition):** `http://localhost:5001`
- **Loghi Tooling:** `http://localhost:8080`

:::{note}
Use `docker compose up -d` to run in detached mode (background).
:::

### 5. Verify the services are running

Check that all services are up:
```bash
docker compose ps
```

You should see three services running: `laypa`, `htr`, and `loghi-tooling`.

### 6. Process your documents

Use the example scripts in `webservice-scripts/` to process your documents through the pipeline. See the [webservice-scripts README](https://github.com/knaw-huc/loghi/tree/main/webservice/webservice-scripts/README.md) for detailed usage instructions.

### 7. Stop the services

When you're done, stop the services:
```bash
docker compose down
```

## Customization

<!-- text from webservice.md and readme.md, I don't actually quite get what it means, requires updates/explanation-->

The web service setup provided here is adaptable and can be customized to fit specific project requirements. For further customization and in-depth information, please refer to the original repositories linked within our toolkit. These resources offer comprehensive documentation on adjusting parameters, understanding the technology behind Loghi, and exploring advanced use cases. Whether you're looking to fine-tune the service to your specific needs or dive into the technicalities of transcription technologies, these repositories are invaluable resources.
