# FAQ

Here are some frequently asked questions about Loghi and their answers to help you get started and troubleshoot common issues.

## My results are not as good as I expected, what can I do?
If you find that the results from Loghi are not meeting your expectations, consider the following steps to improve performance: 
1. **Check Model Compatibility:** Ensure that the models you are using are appropriate for your specific dataset. Different models may perform better on different types of handwriting or document layouts.
2. **Fine-tune Models:** If you have a specific dataset, consider fine-tuning the pre-trained models on your data. This can significantly improve recognition accuracy, especially for unique handwriting styles or layouts. See the [Training and Finetuning Loghi Models](training.md) section for more details on how to fine-tune models.
3. **Review Preprocessing Steps:** Ensure that the images are preprocessed correctly before being fed into the model. This includes checking for image quality, resolution, and ensuring that the images are in a format compatible with Loghi. The default models provided were trained on mostly 300 DPI images, so if you are using lower or higher resolution images, consider resizing them to 300 DPI.
4. **Community Support:** If you continue to experience issues, consider reaching out to the Loghi developers/community through GitHub issues. Sharing your specific challenges can help others provide targeted advice and solutions.

## Inferencing a large number of images is slow, what can I do?
If processing a large number of images with Loghi is slow, consider the following strategies to improve
performance:
1. **Use GPU Acceleration:** Ensure that you are running Loghi with GPU support. If you have a recent NVIDIA GPU, make sure that Docker is configured to utilize it. This can significantly speed up processing times compared to running on CPU.
2. **Batch Processing:** Instead of processing images one by one, try to batch process them. This can reduce overhead and improve overall throughput. You can change your batch_size in the default inference pipeline to handle multiple textlines in a single run, if not already set up to do so.
3. **Use parallel processing:** If you have multiple CPU cores or GPUs available, consider running multiple instances of Loghi in parallel. This can significantly reduce processing time for large datasets. Change the `threads` parameter in the inference pipeline to utilize multiple CPU cores.
4. **Optimize Image Size:** Ensure that the images being processed are of an appropriate size.
5. **Large images can slow down processing times. Consider resizing images to a resolution that balances quality and speed, especially if high resolution is not necessary for your use case.
6. **Monitor System Resources:** Keep an eye on system resources such as CPU, GPU, memory usage and disk usage during processing. If any resource is being maxed out, it may indicate a bottleneck that can be addressed by optimizing the pipeline or upgrading hardware.
7. **Check for Updates:** Ensure that you are using the latest version of Loghi and its dependencies. Performance improvements and bug fixes are regularly released, which can enhance processing speed.
8. **Community Support:** If you continue to experience slow processing times, consider reaching out to the Loghi community through GitHub issues or forums. Sharing your specific setup and challenges can help others provide targeted advice and solutions.

## Training a model takes a long time, what can I do?
Training models can be time-consuming, especially for complex tasks like Handwritten Text Recognition (HTR). Here are some strategies to speed up the training process:
1. **Use Pre-trained Models:** Start with a pre-trained model and fine-tune it on your specific dataset. This can significantly reduce training time compared to training a model from scratch.
2. **Optimize Data Pipeline:** Ensure that your data loading and preprocessing pipeline is efficient. Use techniques like data augmentation and caching to speed up the process. Consider using libraries like `tf.data` or `torch.utils.data` to create efficient data loaders that can handle large datasets without bottlenecks.
3. **Reduce Model Complexity:** If possible, simplify your model architecture. Smaller models generally train faster, but may require more careful tuning to achieve good performance. Experiment with different architectures to find a balance between  
4. speed and accuracy.
5. **Use Mixed Precision Training:** If your hardware supports it, consider using mixed precision training. This can speed up training by using lower precision (e.g., float16) for certain operations while maintaining higher precision (e.g., float32) for others. Libraries like TensorFlow and PyTorch have built-in support for mixed precision training.
6. **Batch Size and Learning Rate:** Experiment with different batch sizes and learning rates. Larger batch sizes can speed up training, but may require adjustments to the learning rate. Use techniques like learning rate scheduling or warm-up to optimize training.
7. **Distributed Training:** If you have access to multiple GPUs or machines, consider using distributed training. This allows you to split the workload across multiple devices, significantly reducing training time. Frameworks like TensorFlow and PyTorch provide built-in support for distributed training.
8. **Monitor Resource Usage:** Keep an eye on your system's resource usage (CPU, GPU, memory) during training. If any resource is being maxed out, it may indicate a bottleneck that can be addressed by optimizing the pipeline or upgrading hardware.
9. **Profile and Optimize Code:** If you are comfortable with programming, consider profiling the training code to identify bottlenecks. Optimizing these areas can lead to performance improvements. Use profiling tools like TensorBoard or PyTorch's built-in profiler to analyze the training process.
10. **Check for Updates:** Ensure that you are using the latest version of Loghi and its dependencies. Performance improvements and bug fixes are regularly released, which can enhance training speed.
11. **Community Support:** If you continue to experience slow training times, consider reaching out to the Loghi community through GitHub issues or forums. Sharing your specific setup and challenges can help others provide targeted advice and solutions. 
12. By implementing these strategies, you should be able to reduce the training time for your models in Loghi, making it more efficient for your HTR tasks.

## Does Loghi work on Apple Silicon (M1/M2/M3)?

Currently, Loghi does not support utilizing Apple Silicon's accelerated hardware capabilities. We understand the importance and potential of supporting this architecture and are actively exploring possibilities to make Loghi compatible with Apple Silicon in the future. For now, users with Apple Silicon devices can run Loghi using emulation or virtualization tools, though this might not leverage the full performance capabilities of the hardware. We appreciate your patience and interest, and we're committed to broadening our hardware support to include these devices.

## How can I cite this software?

If you find this toolkit useful in your research, please cite:
```
@InProceedings{10.1007/978-3-031-70645-5_6,
author="van Koert, Rutger
and Klut, Stefan
and Koornstra, Tim
and Maas, Martijn
and Peters, Luke",
editor="Mouch{\`e}re, Harold
and Zhu, Anna",
title="Loghi: An End-to-End Framework for Making Historical Documents Machine-Readable",
booktitle="Document Analysis and Recognition -- ICDAR 2024 Workshops",
year="2024",
publisher="Springer Nature Switzerland",
address="Cham",
pages="73--88",
abstract="Loghi is a novel framework and suite of tools for the layout analysis and text recognition of historical documents. Scans are processed in a modular pipeline, with the option to use alternative tools in most stages. Layout analysis and text recognition can be trained on example images with PageXML ground truth. The framework is intended to convert scanned documents to machine-readable PageXML. Additional tooling is provided for the creation of synthetic ground truth. A visualiser for troubleshooting the text recognition training is also made available. The result is a framework for end-to-end text recognition, which works from initial layout analysis on the scanned documents, and includes text line detection, text recognition, reading order detection and language detection.",
isbn="978-3-031-70645-5"
}