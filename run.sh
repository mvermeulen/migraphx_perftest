#!/bin/bash
#
# run.sh - script for running basic MIGraphX performance tests.
#
# Parameters - these can be modified by passing in as ENVIRONMENT variables.
#              Default values are found to right of the := variable.

env LD_LIBRARY_PATH=./lib ./bin/perf_onnx ./onnx/resnet50i64.onnx

