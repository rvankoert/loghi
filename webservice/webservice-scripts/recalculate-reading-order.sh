#!/bin/bash

# Check if a directory path is provided; if not, display a message and exit.
if [ -z "$1" ]; then 
    echo "Please provide the path to PageXMLs to be reordered."
    exit 1
fi

# Assign the provided directory path to DIR.
DIR="$1"

# Find all XML files in the specified directory (without going into subdirectories),
# and process them one by one.
find "$DIR" -maxdepth 1 -type f -name "*.xml" | while IFS= read -r input_path; do
  # Extract the filename without the extension.
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"

  # Prepare for the curl request.
  # - "identifier=$filename": Assigns a unique identifier to the request, using the file's name.
  # - "page=@$input_path": Attaches the XML file to be processed.
  # - "border_margin=200": Specifies an additional parameter for the processing, in this case, a border margin.
  # The verbose option (-v) in the curl command is used for displaying detailed information about the request and response.
  curl -v -X POST \
       -F "identifier=$filename" \
       -F "page=@$input_path" \
       -F "border_margin=200" \
       http://localhost:8080/recalculate-reading-order-new
done

