# Imports

# > Standard Libraries
import logging

# > Local Libraries
from processing import process_image
from utils import get_env_variable

# > Third Party Libraries
import gradio as gr


def start_app(laypa_model_path: str, laypa_output: str, queue_size: int,
              concurrency_limit: int, htr_output: str, tooling_output: str,
              laypa_address: str, htr_address: str, tooling_address: str) \
        -> None:
    """
    Initialize and launch a Gradio web application to process images using
    machine learning models for layout analysis, handwriting text recognition,
    and other tooling processes.

    Parameters
    ----------
    laypa_model_path : str
        Filepath to the LayPA model used for layout analysis.
    laypa_output : str
        Directory path where outputs of the LayPA process will be stored.
    queue_size : int
        Maximum number of processes that can be queued at once.
    concurrency_limit : int
        Maximum number of concurrent processes allowed.
    htr_output : str
        Directory path where outputs of the Handwriting Text Recognition
        process will be stored.
    tooling_output : str
        Directory path for storing outputs from various tooling processes.
    laypa_address : str
        Address of the server where LayPA model processing is deployed.
    htr_address : str
        Address of the server where Handwriting Text Recognition model
        processing is deployed.
    tooling_address : str
        Address of the server where additional tooling processes are deployed.

    Returns
    -------
    None
        This function initializes the Gradio app and does not return any value.
    """

    with gr.Blocks(title="Loghi Demo") as demo:
        gr.Markdown("# Loghi Demo")
        gr.Markdown(
            "This demo uses the Laypa model for layout analysis and the Loghi "
            "model for handwritten text recognition. Upload an image and click"
            " submit to process the image.")

        with gr.Tab("Inputs"):
            with gr.Row():
                original_image = gr.Image(
                    type="filepath", label="Original Image")
                with gr.Column():
                    submit_button = gr.Button("Submit", variant="primary")
                    clear_button = gr.ClearButton()
                    status_message = gr.Text(
                        label="Status Message", value="Upload an image...",
                        lines=1)

        with gr.Tab("Laypa Result"):
            with gr.Row():
                with gr.Column(scale=1):
                    gr.Markdown("### Original Image")
                    original_image_display = gr.Image(label="Original Image",
                                                      interactive=False)
                with gr.Column(scale=1):
                    gr.Markdown("### Segmented Image")
                    segmented_image = gr.Image(
                        type="pil", label="Segmented Image")

        with gr.Tab("HTR Results"):
            with gr.Row():
                with gr.Column():
                    gr.Markdown("### Extracted Text Lines")
                    extracted_text_lines = gr.Gallery(
                        label="Extracted Text Lines",
                        preview=True)
            with gr.Row():
                with gr.Column():
                    gr.Markdown("### Transcription Data")
                    htr_results = gr.Dataframe(label="HTR Results")

        with gr.Tab("PageXML"):
            with gr.Column():
                with gr.Accordion(label="View PageXML", open=False):
                    page_xml_viewer = gr.Code(language="html")
                download_pagexml = gr.DownloadButton(
                    label="Download PageXML", variant="primary")

        # HACK: Create hidden text inputs to pass variables to the submit
        # button's callback function
        laypa_model_path = gr.Text(laypa_model_path, visible=False)
        laypa_output = gr.Text(laypa_output, visible=False)
        htr_output = gr.Text(htr_output, visible=False)
        tooling_output = gr.Text(tooling_output, visible=False)
        laypa_address = gr.Text(laypa_address, visible=False)
        htr_address = gr.Text(htr_address, visible=False)
        tooling_address = gr.Text(tooling_address, visible=False)

        submit_button.click(
            fn=process_image,
            inputs=[original_image, laypa_output, laypa_model_path,
                    tooling_output, htr_output, laypa_address, htr_address,
                    tooling_address],
            outputs=[original_image_display, segmented_image,
                     extracted_text_lines, htr_results, status_message,
                     download_pagexml, page_xml_viewer],
            concurrency_limit=concurrency_limit,
        )
        clear_button.click(
            fn=lambda: (None, None, None, None, None,
                        "Upload an image...", None, None),
            outputs=[original_image, original_image_display, segmented_image,
                     extracted_text_lines, htr_results, status_message,
                     download_pagexml, page_xml_viewer],
        )

        # Update the segmented_image and original_image_display to show a
        # loading state
        segmented_image.loading = True
        original_image_display.loading = True
        extracted_text_lines.loading = True
        htr_results.loading = True

    demo.queue(max_size=queue_size).launch()


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')

    laypa_model_path = get_env_variable("LAYPA_MODEL_PATH")
    laypa_output = get_env_variable("LAYPA_OUTPUT_PATH")
    laypa_address = get_env_variable("LAYPA_ADDRESS", "http://localhost:5000")

    queue_size = int(get_env_variable("QUEUE_SIZE", default_value=5))
    concurrency_limit = int(get_env_variable("CONCURRENCY_LIMIT",
                                             default_value=2))

    htr_output = get_env_variable("LOGHI_OUTPUT_PATH")
    htr_address = get_env_variable("LOGHI_ADDRESS", "http://localhost:5001")

    tooling_output = get_env_variable("TOOLING_OUTPUT_PATH")
    tooling_address = get_env_variable("TOOLING_ADDRESS",
                                       "http://localhost:8080")

    start_app(laypa_model_path, laypa_output, queue_size, concurrency_limit,
              htr_output, tooling_output, laypa_address, htr_address,
              tooling_address)
