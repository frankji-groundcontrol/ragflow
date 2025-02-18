#!/bin/bash

# replace env variables in the service_conf.yaml file
rm -rf /ragflow/conf/service_conf.yaml
while IFS= read -r line || [[ -n "$line" ]]; do
    # Use eval to interpret the variable with default values
    eval "echo \"$line\"" >> /ragflow/conf/service_conf.yaml
done < /ragflow/conf/service_conf.yaml.template

/usr/sbin/nginx

export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

PY=python3
if [[ -z "$WS" || $WS -lt 1 ]]; then
  WS=1
fi

# Get number of available GPUs
NUM_GPUS=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader | wc -l)
if [[ $NUM_GPUS -lt 1 ]]; then
  NUM_GPUS=1
fi

function task_exe(){
    while [ 1 -eq 1 ];do
      $PY rag/svr/task_executor.py $1;
    done
}

for ((i=0;i<WS;i++))
do
  # Distribute workers evenly across GPUs using modulo
  gpu_id=$((i % NUM_GPUS))
  CUDA_VISIBLE_DEVICES=$gpu_id task_exe $i &
done

while [ 1 -eq 1 ];do
    $PY api/ragflow_server.py
done

wait;
