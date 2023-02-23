#!/bin/bash

INPUT=/scratch/bulk/input
OUTPUT=/scratch/bulk/output
INTERMEDIATE=/scratch/bulk/intermediate


while true
do
  DIRS=`find /scratch/bulk/input/ -mindepth 1 -maxdepth 1 -mmin +1 -type d -printf "%T@\t%Tc %6k KiB %p\n" | sort -n | cut -d ' ' -f 13`
  echo $DIRS
  for DIR in ${DIRS}; do
    echo $DIR
    COUNTNEW=`find $DIR -mindepth 1 -maxdepth 1 -mmin -5 -type f|wc -l`
    COUNTOLD=`find $DIR -mindepth 1 -maxdepth 1 -type f|wc -l`
    echo $COUNTOLD
    echo $COUNTNEW
    if [ "$COUNTNEW" -eq 0 ] && [ "$COUNTOLD" -gt 0 ]; then
      echo "processing..";
      mv $DIR $INTERMEDIATE/
      DIR=${DIR##*/}
      ./na-pipeline.sh $INTERMEDIATE/$DIR &> $INTERMEDIATE/$DIR.log
      mv $INTERMEDIATE/$DIR $INTERMEDIATE/$DIR.log $OUTPUT/
    fi
  done
  echo "sleeping for 30 seconds..."
  sleep 30
done
