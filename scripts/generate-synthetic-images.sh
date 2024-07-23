#!/bin/bash

set -e
set -o pipefail

# Checking if the correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/fonts/ /path/to/texts/"
    exit 1
fi

# Assigning command line arguments to variables
FONTSDIR="$1"
TEXTDIR="$2"
OUTPUTDIR="/tmp/synthetic"
MAXFILES=10

# Running the Docker command with mounted volumes and passed arguments
docker run -ti \
 -v "$FONTSDIR":"$FONTSDIR" \
 -v "$TEXTDIR":"$TEXTDIR" \
 -v "$OUTPUTDIR":"$OUTPUTDIR" \
 loghi/docker.loghi-tooling \
 /src/loghi-tooling/minions/target/appassembler/bin/MinionGeneratePageImages \
 -add_salt_and_pepper \
 -font_path "$FONTSDIR" \
 -text_path "$TEXTDIR" \
 -output_path "$OUTPUTDIR" \
 -max_files "$MAXFILES"

