# Imports

# > Standard Libraries
import io
import logging
import os
from pathlib import Path
import requests
import shutil
from typing import Optional, Tuple

# > Local Libraries
from utils import await_file, await_directory, await_htr_results, \
    await_xml_update, check_for_segmentation_results

# > Third Party Libraries
import pandas as pd
from PIL import Image


def segment_call(image: Image, laypa_output_path: str, model_path: str,
                 filename: str, identifier: str, address: str) \
        -> Tuple[Optional[Image.Image], Optional[str], str]:
    """
    Sends an image to a segmentation service and checks for the results within
    a specified directory.

    Parameters
    ----------
    image : Image
        The PIL Image object to be segmented.
    laypa_output_path : str
        The directory where the segmentation results are expected to be saved.
    model_path : str
        The path to the segmentation model used by the server.
    filename : str
        The name of the image file as it should be sent to the server.
    identifier : str
        A unique identifier for the segmentation task.
    address : str
        The base URL of the segmentation service.

    Returns
    -------
    Tuple[Optional[Image.Image], Optional[str], str]
        A tuple containing the segmented image (if successful), the path to the
        image, and a status message.
    """
    logging.info("Starting image segmentation...")
    image_byte_array = io.BytesIO()
    image.save(image_byte_array, format='PNG')
    image_byte_array.seek(0)

    url = f"{address}/predict"
    expected_dir = Path(laypa_output_path) / identifier

    # Ensure the directory is prepared
    if expected_dir.exists():
        shutil.rmtree(expected_dir, ignore_errors=True)
    expected_dir.mkdir(parents=True, exist_ok=True)

    files = {'image': (filename, image_byte_array, 'image/png')}
    data = {'identifier': identifier, 'model': model_path}

    response = requests.post(url, files=files, data=data)
    if response.ok:
        logging.info(
            "Segmentation request successful, checking for results...")
        return check_for_segmentation_results(expected_dir, identifier)
    else:
        logging.error(f"Segmentation failed: HTTP {response.status_code}")
        return None, None, f"Segmentation failed: HTTP {response.status_code}"


def extract_baselines_call(mask: io.BytesIO, xml: io.BytesIO,
                           image: io.BytesIO, identifier: str,
                           tooling_output: str, address: str) \
        -> Tuple[Optional[str], str]:
    """
    Sends image data to a baseline extraction service and waits for the
    resulting XML file to be saved.

    Parameters
    ----------
    mask : io.BytesIO
        The binary stream of the mask image used for baseline extraction.
    xml : io.BytesIO
        The binary stream of the initial XML file for baseline data.
    image : io.BytesIO
        The binary stream of the original image.
    identifier : str
        A unique identifier for the extraction task.
    tooling_output : str
        The directory where the baseline extraction XML is expected to be
        saved.
    address : str
        The base URL of the baseline extraction service.

    Returns
    -------
    Tuple[Optional[str], str]
        A tuple containing the path to the XML output file (if successful) and
        a status message.
    """
    logging.info("Extracting baselines...")
    url = f"{address}/extract-baselines"
    xml_output_path = Path(tooling_output) / identifier / f"{identifier}.xml"

    # Prepare the directory
    if xml_output_path.parent.exists():
        shutil.rmtree(xml_output_path.parent)
    xml_output_path.parent.mkdir(parents=True, exist_ok=True)

    files = {
        'mask': (f'{identifier}.png', mask, 'image/png'),
        'xml': (f'{identifier}.xml', xml, 'application/xml'),
        'image': (f'{identifier}.png', image, 'image/png')
    }
    data = {'identifier': identifier}

    response = requests.post(url, files=files, data=data)
    if response.ok:
        logging.info(
            "Baseline extraction request sent successfully, "
            "awaiting response...")
        if await_file(xml_output_path, 60):
            return str(xml_output_path), "Baseline extraction successful."
        return None, "Failed to extract baselines."
    else:
        logging.error(
            f"Failed to extract baselines: HTTP{response.status_code}")
        return None, f"Failed to extract baselines: HTTP{response.status_code}"


def cut_from_image_call(image: io.BytesIO, xml_bytes: io.BytesIO,
                        identifier: str, tooling_output: str, address: str) \
        -> Tuple[bool, str]:
    """
    Sends an image along with its corresponding Page XML to a service to
    perform image cutting based on the XML data.

    Parameters
    ----------
    image : io.BytesIO
        The binary stream of the original image.
    xml_bytes : io.BytesIO
        The binary stream of the Page XML data used for cutting.
    identifier : str
        A unique identifier for the cutting task.
    tooling_output : str
        The directory where the cut images are expected to be saved.
    address : str
        The base URL of the cutting service.

    Returns
    -------
    Tuple[bool, str]
        A tuple containing a boolean indicating success or failure, and a
        status message.
    """
    logging.info("Preparing to cut images from original based on XML...")
    output_dir = Path(f"{tooling_output}/{identifier}/{identifier}")

    if output_dir.exists():
        shutil.rmtree(output_dir, ignore_errors=True)
    output_dir.mkdir(parents=True, exist_ok=True)
    image.seek(0)  # Reset the image pointer to ensure it reads from start

    url = f"{address}/cut-from-image-based-on-page-xml-new"
    files = {
        'image': (f'{identifier}.png', image, 'image/png'),
        'page': (f'{identifier}.xml', xml_bytes, 'application/xml')
    }
    data = {'identifier': identifier, 'output_type': 'png', 'channels': '4'}

    response = requests.post(url, files=files, data=data)
    if response.ok:
        logging.info(
            "Cut request successful, checking for output directory...")
        # Check for the directory for 60 seconds
        if await_directory(output_dir, 60):
            return True, "Image cutting successful."
        return False, "Failed to cut images."
    else:
        logging.error(f"Failed to cut image: HTTP {response.status_code}")
        return False, f"Failed to cut image: HTTP {response.status_code}"


def htr_call(cut_images_dir: str, group_id: str,
             htr_output: str, address: str) -> pd.DataFrame:
    """
    Sends cut images for Handwritten Text Recognition (HTR) processing.

    Parameters
    ----------
    cut_images_dir : str
        The directory containing the cut images to be processed.
    group_id : str
        A group identifier for the HTR processing.
    htr_output : str
        The directory where the HTR results are expected to be saved.
    address : str
        The base URL of the HTR service.

    Returns
    -------
    pd.DataFrame
        A DataFrame containing the HTR results.
    """
    logging.info("Starting Handwritten Text Recognition (HTR)...")
    url = f"{address}/predict"
    ok_count = 0

    # Ensure the directory is ready
    expected_dir = Path(f"{htr_output}/{group_id}")
    if expected_dir.exists():
        shutil.rmtree(expected_dir, ignore_errors=True)
    expected_dir.mkdir(parents=True, exist_ok=True)

    # Process each image file in the directory
    for img_file in Path(cut_images_dir).glob("*.png"):
        with img_file.open('rb') as img:
            files = {
                'image': (img_file.name, img, 'image/png'),
                'group_id': (None, group_id),
                'identifier': (None, img_file.stem),
                'whitelist': (None, 'url_code'),  # example parameter
            }
            response = requests.post(url, files=files)

            if response.ok:
                ok_count += 1
            else:
                logging.error(
                    f"HTR request failed for {img_file.name}: "
                    f"HTTP {response.status_code}")

    logging.info("Awaiting all HTR results to be processed...")
    return await_htr_results(expected_dir, ok_count)


def merge_htr_with_pagexml_call(page_xml_path: str, htr_results_path: str,
                                identifier: str, address: str) -> bool:
    """
    Merges Handwritten Text Recognition (HTR) results with a Page XML file and
    sends the merged data to a service.

    Parameters
    ----------
    page_xml_path : str
        The file path to the Page XML to be updated.
    htr_results_path : str
        The directory containing the HTR results as text files.
    identifier : str
        A unique identifier for the merge task.
    address : str
        The base URL of the service that processes the merging.

    Returns
    -------
    bool
        True if the merge request is successfully processed and the Page XML is
        updated, otherwise False.
    """
    logging.info("Merging HTR results with Page XML...")
    url = f"{address}/loghi-htr-merge-page-xml"
    merged_results_path = Path(htr_results_path) / f"{identifier}.txt"
    page_xml_name = os.path.basename(page_xml_path)

    # Prepare the concatenated results
    with merged_results_path.open('w') as merged_file:
        for htr_file in Path(htr_results_path).glob("*.txt"):
            with htr_file.open('r') as file:
                merged_file.writelines(file)

    # Prepare the files for the request
    with open(page_xml_path, 'rb') as page_file, \
            open(merged_results_path, 'rb') as results_file:
        files = {
            'page': (page_xml_name, page_file, 'application/xml'),
            'results': (f"{identifier}.txt", results_file, 'text/plain'),
            'identifier': (None, identifier)
        }
        response = requests.post(url, files=files)
        if response.ok:
            logging.info("Merge request accepted, awaiting updates...")
            return await_xml_update(page_xml_path)
        else:
            logging.error(f"Merge failed: HTTP {response.status_code}")
            return False


def recalculate_reading_order_call(xml_path: str,
                                   identifier: str,
                                   address: str) -> bool:
    """
    Sends a request to recalculate the reading order in a Page XML file based
    on its updated content.

    Parameters
    ----------
    xml_path : str
        The file path of the Page XML to be recalculated.
    identifier : str
        A unique identifier for the recalculation task.
    address : str
        The base URL of the service that recalculates the reading order.

    Returns
    -------
    bool
        True if the recalculation request is successfully processed and the XML
        is updated, otherwise False.
    """
    logging.info("Recalculating reading order...")
    url = f"{address}/recalculate-reading-order-new"
    files = {
        'page': (os.path.basename(xml_path),
                 open(xml_path, 'rb'),
                 'application/xml'),
        'identifier': (None, identifier),
        'border_margin': (None, '200')  # Example parameter, adjust as needed
    }

    response = requests.post(url, files=files)
    if response.ok:
        logging.info(
            "Reading order recalculation request sent, awaiting response...")
        return await_xml_update(xml_path)
    else:
        logging.error("Failed to recalculate reading order: HTTP "
                      f"{response.status_code}")
        return False


def split_text_line_into_words_call(xml_path: str,
                                    identifier: str,
                                    address: str) -> bool:
    """
    Sends a Page XML file to a service to split text lines into words,
    enhancing text analysis granularity.

    Parameters
    ----------
    xml_path : str
        The file path of the Page XML that contains text lines to be split into
        words.
    identifier : str
        A unique identifier for the splitting task.
    address : str
        The base URL of the service that performs the splitting of text lines
        into words.

    Returns
    -------
    bool
        True if the splitting request is successfully processed and the XML is
        updated, otherwise False.
    """
    logging.info("Splitting text lines into words...")
    url = f"{address}/split-page-xml-text-line-into-words"
    files = {
        'xml': (os.path.basename(xml_path), open(xml_path, 'rb'),
                'application/xml'),
        'identifier': (None, identifier)
    }

    response = requests.post(url, files=files)
    if response.ok:
        logging.info(
            "Text line splitting request accepted, awaiting XML update...")
        return await_xml_update(xml_path)
    else:
        logging.error("Failed to split text lines into words: "
                      f"HTTP {response.status_code}")
        return False
