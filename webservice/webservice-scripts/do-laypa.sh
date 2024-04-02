#!/bin/bash

# Check if the necessary arguments are provided; if not, display a message and exit.
if [ -z "$1" ] || [ -z "$2" ]; then 
    echo "Usage: $0 <path_to_images> <model_path>"
    exit 1
fi

# Assign the provided directory path to DIR and the model path to MODEL_PATH.
DIR="$1"
MODEL_PATH="$2"

# Search for all JPG files within the specified directory.
find "$DIR/" -name '*.jpg' | while IFS= read -r input_path; do
  # Extract the filename without its extension.
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"

  # The curl command posts the image to a prediction service, including:
  # - The image file itself
  # - A unique identifier for the image, derived from its filename
  # - The path to the model to be used for processing the image
  curl -X POST \
       -F "image=@${input_path}" \
       -F "identifier=$filename" \
       -F "model=${MODEL_PATH}" \
       'http://localhost:5000/predict'

done

