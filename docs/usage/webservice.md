# Loghi Web Service

:::{note}
The contents of this page are under review.
:::

This page explains how to run the Loghi web services, which are a set of API endpoints that run on your computer and accept requests from command-line scripts. 

:::{tip}
**Looking for a simple way to transcribe images?** The webservice approach is more complex and intended for advanced users who need programmatic API access. If you want a graphical interface or just need to process some documents, use one of these instead:
- The [inference pipeline script](run-loghi) - simplest command-line approach
- [Gradio interface](gradio.md) - provides a web-based graphical interface
:::

## Directory Overview

The [`webservice/` directory](https://github.com/knaw-huc/loghi/tree/main/webservice) contains:

- `loghi-tooling/`: Configuration for the tooling service
- `webservice-scripts/`: Example scripts showing how to call the APIs for each part of the [pipeline](../introduction.md/#how-loghi-works)
- `docker-compose.yml`: Configuration file to run all services together

## Prerequisites

Before starting, ensure you have:
- Cloned the Loghi repository (see [Installation: Clone the Repository](clone-repo))
- Installed Docker (see [Installation: Install Docker](install-docker))
- Installed Docker Compose (usually included with Docker; verify with `docker compose version`)
- Downloaded Loghi models (see [Installation: Download Models](download-models))
- Completed GPU setup (optional, only if you want GPU acceleration) (see [Installation: Set up GPU](set-up-gpu))

## Getting Started

### 1. Navigate to the webservice directory

From your cloned Loghi repository:
```bash
cd webservice
```

### 2. Configure paths

The `docker-compose.yml` file contains placeholder paths (e.g., `/PATH/TO/...`) that you must update to match your system. Open the file in a text editor and update the following for each service.

#### Understanding volume mounts

Volume mounts connect directories on your computer to directories inside Docker containers:
```yaml
volumes:
  - /your/local/path:/path/inside/container
```

The **left side** (before `:`) is where files are on your computer. The **right side** is where the container sees them. In this configuration, both sides use the same path, so you simply replace the placeholder with your actual path on both sides.

#### Configure Laypa

Find the `laypa:` service and update:

1. **Model path** — replace `/PATH/TO/LAYPA/MODEL/` with the full path to your Laypa model directory (e.g., `/home/downloads/laypa-models/general/baseline/`). This path appears in three places:
   ```yaml
   environment:
     LAYPA_MODEL_BASE_PATH: /PATH/TO/LAYPA/MODEL/
   volumes:
     - '/PATH/TO/LAYPA/MODEL/:/PATH/TO/LAYPA/MODEL/'
   ```

2. **Output path** — replace `/PATH/TO/LAYPA/OUTPUT/` with where you want Laypa output saved (e.g., `/tmp/loghi/laypa/`). This path appears in two places:
   ```yaml
   environment:
     LAYPA_OUTPUT_BASE_PATH: /PATH/TO/LAYPA/OUTPUT/
   volumes:
     - '/PATH/TO/LAYPA/OUTPUT/:/PATH/TO/LAYPA/OUTPUT/'
   ```

#### Configure HTR

Find the `htr:` service and update:

1. **Model path** — replace `/PATH/TO/LOGHI/MODEL/` with the full path to your HTR model directory (e.g., `/home/downloads/htr-models/generic-2023-02-15/`). This path appears in two places:
   ```yaml
   environment:
     LOGHI_MODEL_PATH: '/PATH/TO/LOGHI/MODEL/'
   volumes:
     - '/PATH/TO/LOGHI/MODEL/:/PATH/TO/LOGHI/MODEL/'
   ```

2. **Output path** — replace `/PATH/TO/LOGHI/OUTPUT/` with where you want HTR output saved (e.g., `/tmp/loghi/htr/`). This path appears in two places:
   ```yaml
   environment:
     LOGHI_OUTPUT_PATH: '/PATH/TO/LOGHI/OUTPUT/'
   volumes:
     - '/PATH/TO/LOGHI/OUTPUT/:/PATH/TO/LOGHI/OUTPUT/'
   ```

#### Configure Loghi Tooling

Find the `loghi-tooling:` service and update:

1. **Configuration file** — replace `/PATH/TO/LOGHI/TOOLING/CONFIGURATION.yml` with the full path to `configuration.yml` in your cloned repository (e.g., `/home/loghi/webservice/loghi-tooling/configuration.yml`). This path appears in the `command:` line and in `volumes:`:
   ```yaml
   command: '... server /PATH/TO/LOGHI/TOOLING/CONFIGURATION.yml'
   volumes:
     - '/PATH/TO/LOGHI/TOOLING/CONFIGURATION.yml:/PATH/TO/LOGHI/TOOLING/CONFIGURATION.yml'
   ```

2. **Storage location** — replace `/PATH/TO/STORAGE/LOCATION/` with where you want tooling output saved (e.g., `/tmp/loghi/tooling/`). This path appears in two places:
   ```yaml
   environment:
     STORAGE_LOCATION: /PATH/TO/STORAGE/LOCATION/
   volumes:
     - '/PATH/TO/STORAGE/LOCATION/:/PATH/TO/STORAGE/LOCATION/'
   ```

### 3. Remove GPU configuration (if not using GPU)

If you don't have NVIDIA GPU support set up, you need to remove the GPU configuration from `docker-compose.yml`:

1. Open `docker-compose.yml` in a text editor
2. Find and delete or comment out the `deploy:` sections in both the `laypa:` and `htr:` services:
   ```yaml
   # Remove these lines:
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

### 4. Start the services

Start all services:
```bash
docker compose up
```

The services will start and display logs. Logs from all services will be mixed together, which can be difficult to read. The services will be ready when they stop producing startup messages.

The API services are now running on these ports:
- **Laypa (Layout Analysis):** port 5000
- **Loghi HTR (Text Recognition):** port 5001
- **Loghi Tooling:** port 8080

These are API endpoints that accept HTTP requests from scripts, not web pages you can visit in a browser.

:::{tip}
Use `docker compose up -d` to run services in the background (detached mode). Then check their status with `docker compose ps` and view individual service logs with `docker compose logs <service-name>`.
:::

### 5. Verify the services

Check that all services are running:
```bash
docker compose ps
```

All three services should show status "Up".

To verify Laypa is responding, check its status endpoint:
```bash
curl http://localhost:5000/status
```

Or open `http://localhost:5000/status` in your browser. You should see a JSON response. Even if it shows an error like "Missing identifier in form", this confirms the service is running and responding - it's just telling you it needs proper API parameters to process requests.

#### Troubleshooting

If any services show "Restarting" or "Exit" status, check the logs:
```bash
docker compose logs laypa --tail 50
docker compose logs htr --tail 50
docker compose logs loghi-tooling --tail 50
```

**Common issues:**

| Error | Solution |
|-------|----------|
| `FileNotFoundError: LAYPA_MODEL_BASE_PATH: ... is not found` | Check that volume mount points to your actual model directory and that `LAYPA_MODEL_BASE_PATH` matches the container path |
| `could not select device driver "nvidia"` | Remove the `deploy:` sections from the services (see step 3) |

:::{note}
The pre-built Docker images (especially HTR) may have compatibility issues. If you encounter persistent problems, build the images from source by running `./docker/buildAll.sh` from the main loghi directory before starting the webservice.
:::

If problems persist, consider using the simpler [inference pipeline](run-loghi) instead.

### 6. Process your documents

The services are APIs that accept HTTP requests. Use the example scripts in `webservice-scripts/` to process documents:

```bash
cd webservice-scripts
# See the README for usage instructions
```

See the [webservice-scripts README](https://github.com/knaw-huc/loghi/tree/main/webservice/webservice-scripts/README.md)[^webservice-scripts-readme] for detailed examples of calling each API endpoint.

### 7. Stop the services

When finished:
```bash
docker compose down
```

## Understanding the Architecture

The webservice consists of three components:

1. **Laypa**: Analyzes document layout and detects text baselines
2. **Loghi HTR**: Performs handwritten text recognition on detected text lines
3. **Loghi Tooling**: Provides utilities for post-processing PageXML output (merging results, recalculating reading order, etc.)

These services work together in a pipeline, with each service handling a specific part of the transcription process. The webservice-scripts demonstrate how to chain these services together.

## Additional Notes

- The webservice provides more flexibility than the basic inference pipeline, allowing you to call individual services and integrate them into custom workflows
- All services are stateless APIs - they don't store results permanently. Output files are written to the configured output directories
- For production use, you may need to adjust worker counts, queue sizes, and other performance parameters in the environment variables

[^webservice-scripts-readme]: https://github.com/knaw-huc/loghi/tree/main/webservice/webservice-scripts/README.md