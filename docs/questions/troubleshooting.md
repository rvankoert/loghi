# Troubleshooting

:::{note}
The contents of this page are under review.
:::

Here are some common issues that you could encounter. If you have a specific error message, you may also look at the open and close issues on the [GitHub Issues page](https://github.com/knaw-huc/loghi/issues)[^github-issues] and see if someone else has encountered the same problem. Please [open a new issue](open-github-issue) if you don't find a solution to your error.

## Path Issues
### The error message says "No such file or directory". What should I do?
This is probably the most common issue you may encounter. Here are some steps to diagnose the problem:

1. **Check if the file or directory exists.** Use `ls` to list the contents of the directory:
   ```bash
   ls /path/to/the/file/or/directory
   ```
   If you get "No such file or directory" again, the path is wrong or the file does not exist.

2. **Check for typos.** Compare your path character by character. Common mistakes include missing letters, wrong capitalization (Linux paths are case-sensitive), and extra or missing slashes.

3. **Use an absolute path instead of a relative one.** A relative path like `models/my-model` depends on your current working directory. Use the full absolute path instead (e.g., `/home/user/models/my-model`). You can easily get the full path to a folder or file by right-clicking on it in the file manager, selecting "Copy", and pressing `Ctrl + Shift + V` to paste the full path into the terminal. Alternatively, you can find the absolute path of a file or directory by navigating to it in the terminal and running:
   ```bash
   pwd
   ```

4. **Check your current working directory.** If you must use a relative path, make sure you are in the right directory first:
   ```bash
   pwd
   ```

5. **Check for spaces in the path.** If any folder or file name contains spaces, wrap the entire path in quotes:
   ```bash
   ls "/path/to/my folder/file.txt"
   ```

## Docker

### Docker doesn't seem to be working. What should I do?
Make sure Docker is installed and running. You can check by running:
```bash
docker --version
```
If Docker is installed but not running, start it with:
```bash
sudo systemctl start docker
```

### I get "permission denied" when running Docker commands. What should I do?
Your user may not be in the Docker group. Add yourself to the group and then log out and back in:
```bash
sudo usermod -aG docker $USER
```

### GPU support is not working inside Docker. What should I do?
Make sure that both NVIDIA drivers and the NVIDIA Container Toolkit are installed correctly. You can verify by running:
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```
If the first command works but the second does not, the NVIDIA Container Toolkit may not be installed. See [Installation: Set up GPU](set-up-gpu) for instructions.

### Docker cannot find my files or models. What should I do?
Docker containers cannot access files on your host system by default. You need to mount host directories into the container using the `-v` (volume) flag. For example:
```bash
docker run -v /home/user/models:/models loghi/docker.htr
```
This makes the host directory `/home/user/models` available inside the container at `/models`. Make sure the path on the left side of `:` is a valid absolute path on your host, and that the path on the right side matches what the application expects inside the container.

## Others

### I get the message "bash: ./scripts/inference-pipeline.sh: Permission denied" when trying to run the inference script. What should I do?
You may need to change the permissions of the script by running:
```bash
chmod +x scripts/inference-pipeline.sh
```

### I get "ModuleNotFoundError" or "No matching distribution found" when installing dependencies. What should I do?
These errors mean a required Python package is missing or incompatible with your Python version. Try the following:
1. Make sure you are using a supported Python version (3.8 or higher).
2. Upgrade pip before installing:
   ```bash
   pip install --upgrade pip
   ```
3. Install the dependencies from the component's `requirements.txt`:
   ```bash
   pip install -r requirements.txt
   ```
4. If a specific package fails to build, you may need to install system-level dependencies first (e.g., `sudo apt install python3-dev build-essential`).

### My virtual environment doesn't seem to be active. What should I do?
If you are using a virtual environment, make sure it is activated before running any commands:
```bash
source venv/bin/activate
```
You should see the environment name (e.g., `(venv)`) in your terminal prompt when it is active.

### My custom dataset is not being recognized. What should I do?
Make sure your dataset is formatted correctly and that the paths to the images and annotations are correct. Check that the file extensions match what Loghi expects (e.g., `.jpg` for images, `.xml` for PageXML annotations).

### I got a runtime error. What should I do?
You can try to verify that the paths to your models are correct and that the models are compatible with your version of Loghi.

### I have issues with the performance. What should I do?
You can consider checking your GPU settings and ensuring that Docker is configured to utilize GPU resources effectively. On Linux you could use `nvidia-smi` or `nvtop` to check if the GPU is being used correctly.

(open-github-issue)=
### I cannot find a solution to my error in this page or the GitHub Issues. What should I do?
Please follow the steps below to open a new issue:
1. Go to [GitHub Issues page](https://github.com/knaw-huc/loghi/issues)[^github-issues].
2. Click the green "New issue" button in the upper right corner of the page. 
3. Add a clear title for your issue and provide a description as detailed as possible. You may consider this format:
```md
## Description
Brifely describe the problem and what you were trying to do. 
## Steps to reproduce
1.
2.
3.
## Expected vs actual behavior
Describe what was expected and what actually happened.
## Logs/Error message
Paste the logs or the full error message here.
## Environment details
OS:
Python version:
Docker version:
Install method:
```

[^github-issues]: https://github.com/knaw-huc/loghi/issues
