# Troubleshooting

<!-- content to being updated -->

Here are some common issues that you could encounter. If you have a specific error message, you may also look at the open and close issues on the [GitHub Issues page](https://github.com/knaw-huc/loghi/issues) and see if someone else has encountered the same problem. Please [open a new issue] (#i-cannot-find-a-solution-to-my-error-in-this-page-or-the-github-issues-what-should-i-do) if you don't find a solution to your error.

## Installation

### I got a runtime error. What should I do?
You can try to verify that the paths to your models are correct and that the models are compatible with your version of Loghi.
<!-- update this part with more details -->

### I have issues with the performance. What should I do?
You can consider checking your GPU settings and ensuring that Docker is configured to utilize GPU resources effectively. On Linux you could use `nvidia-smi` or `nvtop` to check if the GPU is being used correctly.
<!-- update this part with more details -->

### What should I do if I get the message "bash: ./scripts/inference-pipeline.sh: Permission denied" when trying to run the inference script?
You may need to change the permissions of the script by running:
```bash
chmod +x scripts/inference-pipeline.sh
```

### The error message says "No such file or directory". What should I do?
You can verify the file name or directory in the command line: Does the file exist at all? Is the directory an absolute one or a relative one? Which folder are you currently in?
<!-- update this part with more details -->

## using Docker
- Ensure that Docker is installed and running correctly on your system.
- If you encounter permission issues, try adding your user to the Docker group.
- If you experience issues with GPU support, ensure that NVIDIA drivers and Docker are correctly configured to utilize GPU resources.
- If you run into path issues, ensure that everything is mapped correctly using volume mappings.

## using the source code directly
- If you encounter problems during installation, ensure that all dependencies are correctly installed.
- If you are using a virtual environment, ensure that it is activated before running any commands.
- If you are using a custom dataset, ensure that it is formatted correctly and that the paths to the images and annotations are correct.


### I cannot find a solution to my error in this page or the [GitHub Issues](https://github.com/knaw-huc/loghi/issues). What should I do?
Please follow the steps below to open a new issue:
1. Go to [GitHub Issues](https://github.com/knaw-huc/loghi/issues).
2. Click the green "New issue" button in the upper right corner of the page. 
3. Please add a clear title for your issue and provide a description as detailed as possible. You may consider this format:
```md
## Description
Brifely describe the problem and what you were trying to do. 
## Steps to reproduce
## Expected behavior
## Actual behavior
## Logs/Error message
Paste the logs or the full error message here.
## Environment
OS:
Docker version:
```
<!-- update this part with images? -->
