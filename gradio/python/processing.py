# Imports

# > Standard Libraries
import logging
import os
from pathlib import Path

# > Local Libraries
from api_calls import (
    cut_from_image_call,
    extract_baselines_call,
    htr_call,
    merge_htr_with_pagexml_call,
    recalculate_reading_order_call,
    segment_call,
    split_text_line_into_words_call,
)

# > Third Party Libraries
from PIL import Image
from utils import file_to_bytes, save_cut_images, setup_image_bytes, xml_to_string


def process_image(
    file_path: str,
    laypa_output_path: str,
    model_path: str,
    tooling_output: str,
    htr_output: str,
    laypa_address: str,
    htr_address: str,
    tooling_address: str,
) -> None:
    """
    Processes an image through various stages including layout analysis,
    baseline extraction, image cutting, and handwriting text recognition
    using specified model paths and server addresses.

    This function coordinates the steps needed to fully process an image from
    the initial layout analysis to the final text recognition, ensuring that
    each step's output is appropriately managed and utilized in subsequent
    steps.

    Parameters
    ----------
    file_path : str
        Path to the input image file.
    laypa_output_path : str
        Directory for storing results from the LAYPA layout analysis.
    model_path : str
        Path to the LAYPA segmentation model.
    tooling_output : str
        Directory for storing results from various tooling processes.
    htr_output : str
        Directory for storing results from Handwriting Text Recognition
        processes.
    laypa_address : str
        Server address for the LAYPA model processing.
    htr_address : str
        Server address for the Handwriting Text Recognition model processing.
    tooling_address : str
        Server address for additional tooling processes.

    Returns
    -------
    None
    """
    file_name = os.path.basename(file_path)
    identifier = Path(file_name).stem

    try:
        image = Image.open(file_path)
        logging.info("Image loaded successfully.")
    except IOError as e:
        logging.error(f"Failed to load image: {e}")
        return

    try:
        # Step 0: Show the loaded image
        yield image, None, None, None, "Image loaded successfully, starting processing...", None, None

        # Step 1: Perform segmentation
        segmented_image, laypa_result_location, segment_msg = segment_call(
            image, laypa_output_path, model_path, file_name, identifier, laypa_address
        )
        logging.info(f"Segmentation completed: {segment_msg}")
        yield image, segmented_image, None, None, segment_msg, None, None
        if not segmented_image:
            return

        # Step 2: Extract baselines
        xml_path = os.path.join(laypa_result_location, f"{identifier}.xml")
        xml_bytes = file_to_bytes(xml_path)
        mask_bytes, image_bytes = setup_image_bytes(segmented_image, image)
        new_xml, baseline_msg = extract_baselines_call(
            mask_bytes, xml_bytes, image_bytes, identifier, tooling_output, tooling_address
        )
        logging.info(f"Baseline extraction message: {baseline_msg}")
        yield image, segmented_image, None, None, baseline_msg, None, None

        # Step 3: Cut images from the original using the new XML
        new_xml_bytes = file_to_bytes(new_xml)
        cut_success, cut_msg = cut_from_image_call(image_bytes, new_xml_bytes, identifier, tooling_output, tooling_address)
        logging.info(f"Image cutting completed: {cut_msg}")
        yield image, segmented_image, None, None, cut_msg, None, None
        if not cut_success:
            return

        # Step 4: Perform handwritten text recognition
        cut_images = save_cut_images(identifier, tooling_output)
        yield image, segmented_image, cut_images, None, cut_msg, None, None
        cut_images_dir = os.path.join(tooling_output, identifier, identifier)
        htr_results = htr_call(cut_images_dir, identifier, htr_output, htr_address)
        cut_images = save_cut_images(identifier, tooling_output, captions=htr_results)
        logging.info("HTR completed.")
        yield image, segmented_image, cut_images, htr_results, "HTR Complete", None, None

        # Step 5: Merge HTR results with Page XML
        merge_success = merge_htr_with_pagexml_call(new_xml, Path(htr_output) / identifier, identifier, tooling_address)
        if not merge_success:
            return
        yield image, segmented_image, cut_images, htr_results, "HTR results merged with Page XML.", None, None

        # Step 6: Recalculate reading order
        recalc_success = recalculate_reading_order_call(new_xml, identifier, tooling_address)
        if not recalc_success:
            return
        yield image, segmented_image, cut_images, htr_results, "Reading order recalculated.", None, None

        # Step 7: Split text lines into words
        split_success = split_text_line_into_words_call(new_xml, identifier, tooling_address)
        final_status = "Splitting lines into words complete." if split_success else "Failed to split text lines into words."
        yield image, segmented_image, cut_images, htr_results, final_status, None, None
        logging.info(final_status)

        # Step 8: Return the final PageXML as a string
        final_page_xml_path = os.path.join(tooling_output, identifier, identifier + ".xml")
        xml_string = xml_to_string(final_page_xml_path)
        yield image, segmented_image, cut_images, htr_results, "Workflow complete.", final_page_xml_path, xml_string

    except Exception as e:
        logging.error(f"Processing failed: {e}")
