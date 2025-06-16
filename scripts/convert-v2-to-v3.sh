#!/bin/bash
set -e


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_model_path> <output_model_path>"
    echo "Example: $0 /path/to/v2_model /path/to/v3_model/"
    exit 1
fi

input_model_path=$1
output_model_path=$2
output_model_path_dirname=$(dirname "$output_model_path")

# Check for duplicate mount points
if [ "$input_model_path" = "$output_model_path_dirname" ]; then
    VOLUMES="-v $input_model_path:$input_model_path"
else
    VOLUMES="-v $input_model_path:$input_model_path -v $output_model_path_dirname:$output_model_path_dirname"
fi

# This script converts the legacy loghi models which were based on keras v2 to the new loghi models based on keras v3
docker run --rm -e HOME=/tmp -u $(id -u "${USER}"):$(id -g "${USER}") $VOLUMES loghi/docker.htr:2.2.21 \
    bash -c "set -e; python3 -m pip install --user -r /src/loghi-htr/utils/convert-v2-to-v3/requirements.txt;
python3 /src/loghi-htr/utils/convert-v2-to-v3/convert.py --savedmodel_dir $input_model_path --output_directory $output_model_path
"
