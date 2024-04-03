#!/bin/bash

cleanup() {
    # Gracefully shut down the gunicorn processes
    docker stop "$container_id"
    docker rm  "$container_id"
    sleep 5  # give processes some time to exit gracefully
    # Cleanup: delete the temporary output directory
    rm -rf "$TEMP_OUTPUT_DIR"
    # Display the result
    echo $result
}

# Register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

if [ -z "$1" ]; then
    echo "Please provide the path to the model as the first argument."
    exit 1
fi

# Starting the API
export GUNICORN_RUN_HOST='0.0.0.0:5000'
export GUNICORN_WORKERS=1
export GUNICORN_THREADS=1
export GUNICORN_ACCESSLOG='-'

# Create a temporary output directory
TEMP_OUTPUT_DIR=$(mktemp -d)

export LOGHI_MODEL_PATH="$1"
export LOGHI_BATCH_SIZE=300
export LOGHI_OUTPUT_PATH="$TEMP_OUTPUT_DIR"
export LOGHI_MAX_QUEUE_SIZE=50000

export LOGGING_LEVEL="DEBUG"
export LOGHI_GPUS="-1"

# Start the API server in docker
container_id=$(docker run -u $(id -u ${USER}):$(id -g ${USER}) \
    -v $LOGHI_MODEL_PATH:$LOGHI_MODEL_PATH \
    -v $TEMP_OUTPUT_DIR:$TEMP_OUTPUT_DIR \
    -e LOGHI_MODEL_PATH=$LOGHI_MODEL_PATH \
    -e LOGHI_BATCH_SIZE=300 \
    -e LOGHI_OUTPUT_PATH="$TEMP_OUTPUT_DIR" \
    -e LOGHI_MAX_QUEUE_SIZE=50000 \
    -e LOGGING_LEVEL="DEBUG" \
    -e LOGHI_GPUS="-1" \
    --name htr-api-test \
    -p 5000:5000 -d \
    loghi/docker.htr \
        sh -c 'cd api && /usr/local/bin/gunicorn --workers=1 --threads=1 -b :5000 "app:create_app()"')

echo "containerid: "$container_id
# Assuming the server takes a few seconds to start up, we sleep for a while
while [ $(curl -w "%{http_code}" -s -o /dev/null localhost:5000/) == "000" ]; do
  echo waiting for webservice to start
  sleep 5s
done

# Calling the API on test images
DIR="../loghi-htr/tests/data"

for input_path in $(find $DIR -name '*.png');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  group_id=`echo $filename|cut -d "-" -f1`
  echo $filename
  curl -X POST -F "image=@$input_path" -F "group_id=$group_id" -F "identifier=$filename" http://localhost:5000/predict
done

# Add a delay to give the prediction some time
count=0
for ((i=0; i<10; i++)); do
  if [[ -d "$TEMP_OUTPUT_DIR/$group_id/" ]]; then
    break;
  else
    echo waiting for results to be generated
    sleep 5s
  fi
done

result="All tests passed!"

# Checking if the output files exist
for input_path in $(find $DIR -name '*.png');
do
  filename=$(basename -- "$input_path")
  filename="${filename%.*}"
  group_id=`echo $filename | cut -d "-" -f1`
  output_path="$TEMP_OUTPUT_DIR/$group_id/$filename.txt"
  if [ ! -f "$output_path" ]; then
    result="Error: Expected output file $output_path not found!"
    break
  fi
done
