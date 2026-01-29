# Troubleshooting

## Common Issues
- For runtime errors, verify that the paths to your models are correct and that the models are compatible with your version of Loghi.
- If you experience performance issues, consider checking your GPU settings and ensuring that Docker is configured to utilize GPU resources effectively. On Linux you could use `nvidia-smi` or `nvtop` to check if the GPU is being used correctly.
- If you have a specific error message, search the issues to see if someone else has encountered the same problem. If not, please open a new issue with detailed information about your setup and the error.
- For any other issues, please refer to the [GitHub Issues](https://github.com/knaw-huc/loghi/issues).
- If you get the message "bash: ./scripts/inference-pipeline.sh: Permission denied" when trying to run the inference script, you may need to change the permissions of the script. You can do this by running:
```bash
chmod +x scripts/inference-pipeline.sh
```

## using Docker
- Ensure that Docker is installed and running correctly on your system.
- If you encounter permission issues, try adding your user to the Docker group.
- If you experience issues with GPU support, ensure that NVIDIA drivers and Docker are correctly configured to utilize GPU resources.
- If you run into path issues, ensure that everything is mapped correctly using volume mappings.

## using the source code directly
- If you encounter problems during installation, ensure that all dependencies are correctly installed.
- If you are using a virtual environment, ensure that it is activated before running any commands.
- If you are using a custom dataset, ensure that it is formatted correctly and that the paths to the images and annotations are correct.