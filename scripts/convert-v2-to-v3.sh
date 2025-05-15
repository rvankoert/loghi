#!/bin/bash

input_model_path=$1
output_model_path=$2
output_model_path_dirname=$(dirname $output_model_path)
# This script converts the legacy loghi models which were based on keras v2 to the new loghi models based on keras v3
docker run --rm -v $input_model_path:$input_model_path -v $output_model_path_dirname:$output_model_path_dirname loghi/docker.htr:2.2.17 \
    bash -c "python3 -m pip install -r /src/loghi-htr/utils/convert-v2-to-v3/requirements.txt
python /src/loghi-htr/utils/convert-v2-to-v3/convert.py --input_model_path $input_model_path --output_model_path $output_model_path
"