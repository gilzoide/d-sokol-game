#!/bin/sh

python -m glad --generator c --out-path src --no-loader --reproducible --local-files --api 'gl=3.3,gles2=3.0'
