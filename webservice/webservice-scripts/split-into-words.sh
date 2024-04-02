#!/bin/bash

# Check if a directory path is provided; if not, display a message and exit.
if [ -z "$1" ]; then 
    echo "Please provide the path to PageXMLs which text lines should be split into words."
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

  # Prepare the curl request to send each XML file to the server for processing.
  # - "identifier=$filename": Provides a unique identifier for the request, using the filename.
  # - "xml=@$input_path": Attaches the XML file that contains the text lines to be split into words.
  curl -X POST \
       -F "identifier=$filename" \
       -F "xml=@$input_path" \
       http://localhost:8080/split-page-xml-text-line-into-words
done

