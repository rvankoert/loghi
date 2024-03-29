#!/bin/bash

# Check if the path to images has been provided; if not, display an error message and exit.
if [ -z "$1" ]; then 
    echo "Please provide the path to images and pageXML to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"."
    exit 1
fi

# Assign the first argument to DIR, which is the directory containing the images.
DIR="$1"

# Find all JPEG files in the specified directory, including its subdirectories.
find "$DIR/" -name '*.jpg' | while read input_path; do
  # Extract the filename from the input path.
  filename=$(basename -- "$input_path")
  # Remove the file extension to get the base filename.
  base="${filename%.*}"

  # The `image` field attaches the original image file for processing.
  # The `page` field specifies the corresponding PageXML file, which must be located in a subdirectory named 'page'.
  # The `identifier` field provides a unique name for the image, used for referencing the processed image.
  # The `output_type` field determines the format of the processed image, set to 'png' here.
  # The `channels` field specifies the number of color channels for the output image, with '4' indicating RGBA (including transparency).
  curl -X POST -F "image=@${input_path}" \
        -F "page=@${DIR}/page/${base}.xml" \
        -F "identifier=${base}" \
        -F "output_type=png" \
        -F "channels=4" \
        http://localhost:8080/cut-from-image-based-on-page-xml-new
done

