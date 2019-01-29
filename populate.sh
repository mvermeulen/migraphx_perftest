#!/bin/bash
#
# make local copies of MIGraphX components needed for performance testing
REPOSITORY=${REPOSITORY:="/home/mev/source/AMDMIGraphX"}

build=${REPOSITORY}/build

cp $build/src/onnx/perf_onnx bin/perf_onnx
if [ -f $build/src/onnx/perf_onnx2 ]; then
    cp $build/src/onnx/perf_onnx2 bin/perf_onnx2
else
    cp $build/src/onnx/perf_onnx bin/perf_onnx2
fi
cp $build/src/*.so lib/
cp $build/src/onnx/*.so lib/
cp $build/src/targets/gpu/*.so lib/
cp $build/src/targets/cpu/*.so lib/
