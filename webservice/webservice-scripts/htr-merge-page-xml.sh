#!/bin/bash

# Check if the necessary number of arguments is provided.
if [ -z "$1" ] || [ -z "$2" ]; then 
    echo "Usage: $0 <path_to_pagexml> <path_to_results>"
    exit 1
fi

# Assign arguments to variables for clearer reference.
pageXML="$1"
results="$2"

# Extract the base filename without its extension for use as an identifier.
filename=$(basename -- "$pageXML")
filename="${filename%.*}"

# Display the filename being processed.
echo "$filename"

# # The 'curl' command sends data to the server for processing, including:
# - "page=@$pageXML": The PageXML file to be processed.
# - "results=@$results": The HTR results txt file.
# - "identifier=$filename": A unique identifier for the request, derived from the PageXML filename.
curl -X POST -F "page=@$pageXML" \
     -F "results=@$results" \
     -F "identifier=$filename" \
     http://localhost:8080/loghi-htr-merge-page-xml

