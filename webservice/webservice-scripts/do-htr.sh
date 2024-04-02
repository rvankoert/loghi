#!/bin/bash

# Ensure that a directory path is provided as an argument; if not, display a message and exit
if [ -z "$1" ]; then 
    echo "Please provide the path to line images."
    exit 1
fi

# Assign the provided directory path to DIR
DIR="$1"

# Search for all PNG files within the specified directory and its subdirectories
find "$DIR" -name '*.png' | while read input_path; do
  # Extract the filename with its extension
  filename=$(basename -- "$input_path")
  # Remove the extension from the filename to get the identifier
  base="${filename%.*}"
  # Extract the group_id from the filename, assuming it is before the first '-' character
  group_id=$(echo "$filename" | cut -d "-" -f1)
  # Output the base filename for logging or debugging
  echo "$base"

    # Below, the 'curl' command is used to POST the image along with its metadata to the web service.
  # - "image=@${input_path}": Attaches the actual text line image for processing.
  # - "group_id=$group_id": Specifies the identifier for the group the text line image belongs to.
  # - "identifier=$base": Provides the text line image name without the extension.
  # - "whitelist=model_name": Optional field to include a specific key in the model config.
  # - "whitelist=git_hash": Optional field to include another specific key in the model config.
  curl -X POST \
    -F "image=@${input_path}" \
    -F "group_id=$group_id" \
    -F "identifier=$base" \
    -F "whitelist=model_name" \
    -F "whitelist=git_hash" \
    http://localhost:5001/predict
done

