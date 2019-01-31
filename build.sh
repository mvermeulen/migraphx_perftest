#!/bin/bash
#
# build.sh - script for building MIGraphX performance tests.
OUTPUT_DIR=${OUTPUT_DIR:=`pwd`/output}
TIMESTAMP=${TIMESTAMP:=`date '+%Y-%m-%d-%H:%M:%S'`}

# The following steps are done only once.
if [ ! -d AMDMIGraphX ]; then
    git clone https://github.com/ROCmSoftwarePlatform/AMDMIGraphX
fi

which rbuild
result=$?
if [ $result != 0 ]; then
    pip install https://github.com/RadeonOpenCompute/rbuild/archive/master.tar.gz > $OUTPUT_DIR/install-rbuild.${TIMESTAMP}.txt 2>&1
fi

# Update the sources to the latest
cd AMDMIGraphX
echo "Updating sources (see $OUTPUT_DIR/git-pull.${TIMESTAMP}.txt)"
git pull > $OUTPUT_DIR/git-pull.${TIMESTAMP}.txt 2>&1

# Build new copies
echo "Building MIGraphX (see $OUTPUT_DIR/rbuild.${TIMESTAMP}.txt)"
rbuild build -d depend --cxx=/opt/rocm/bin/hcc > $OUTPUT_DIR/rbuild.${TIMESTAMP}.txt 2>&1

# Run the tests to make sure all is OK
echo "Checking MIGraphX (see $OUTPUT_DIR/check.${TIMESTAMP}.txt)"
cd build && make check >$OUTPUT_DIR/check.${TIMESTAMP}.txt 2>&1
cd ../..

if grep "100% tests passed" $OUTPUT_DIR/check.${TIMESTAMP}.txt; then
    cp AMDMIGraphX/build/src/*.so lib
    cp AMDMIGraphX/build/src/onnx/*.so lib    
    cp AMDMIGraphX/build/src/targets/*/*.so lib    
    cp AMDMIGraphX/build/src/onnx/perf_onnx bin
else
    echo "FAIL - build and test run failed"
fi

