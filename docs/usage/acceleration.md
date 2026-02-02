# GPU Acceleration

To harness the full power of Loghi for faster processing, running it on a GPU is recommended. For users with NVIDIA GPUs, ensure you have NVIDIA Docker installed or your Docker setup supports GPU acceleration. This allows Loghi to utilize GPU resources for processing tasks, significantly speeding up operations like image segmentation with Laypa and text recognition with Loghi HTR.

Setting up Docker to run with GPU support involves installing NVIDIA's Docker extension and specifying the use of a GPU when running a Docker container. For detailed instructions on enabling Docker to work with your NVIDIA GPU, please refer to the official NVIDIA Docker documentation.

Note: Running Loghi with GPU acceleration is particularly beneficial for processing large datasets or when high throughput is required. Ensure your system meets the necessary hardware and software requirements for optimal performance.