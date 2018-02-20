#!/bin/bash

WORKER_TEMPLATE=$1
WORKER_DIR=${2}${SLURM_PROCID}

cp -r ${WORKER_TEMPLATE} ${WORKER_DIR} 

if [ $? -ne 0 ]
then
  echo "Setting up worker directories failed!!"
  exit 255
fi

exit 0
