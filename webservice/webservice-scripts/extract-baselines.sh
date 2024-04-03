#!/bin/bash

# Check if the path to images is provided; if not, display a message and exit.
if [ -z "$1" ]; then 
    echo "Please provide the path to images and pageXML to be converted. The pageXML must be one level deeper than the images in a directory called \"page\"."
    exit 1
fi

# Assign the provided directory path to DIR.
DIR="$1"

# Search for all PNG files within the "page" subdirectory of the specified directory.
find "$DIR/page/" -name '*.png' | while IFS= read -r input_path; do
  # Extract the filename without its extension.
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  
  # Assume the base path for both the mask and the xml is the same, without the extension.
  base="${input_path%.*}"

  # Assuming the original image has the same filename but is located directly under $DIR.
  original_image_path="${DIR}/${filename}.jpg"

  # The 'curl' command sends data to the server for processing.
  # The 'mask' field is the path to the .png file in the "page" directory.
  # The 'xml' field is the path to the corresponding .xml file in the "page" directory.
  # The 'image' field is the path to the original image, assumed to be in the parent directory of "page".
  # The 'identifier' field provides a unique identifier for the request, based on the filename.
  curl -X POST \
       -F "mask=@$base.png" \
       -F "xml=@$base.xml" \
       -F "image=@$original_image_path" \
       -F "identifier=$filename" \
       http://localhost:8080/extract-baselines
done

