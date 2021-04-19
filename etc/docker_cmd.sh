#!/bin/bash

jupyter notebook --allow-root -y --no-browser --notebook-dir=${PROJECT_DIR} \
    --certfile=${SSL_CERT_PEM} --keyfile=${SSL_CERT_KEY} --ip='*' \
    --config=${CONFIG_PATH}