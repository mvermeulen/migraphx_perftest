#!/bin/bash
#
# build.sh - script for building MIGraphX performance tests.


# The following steps are done only once.
if [ ! -d AMDMIGraphX ]; then
    git clone https://github.com/ROCmSoftwarePlatform/AMDMIGraphX
fi

which rbuild
result=$?
if [ $result != 0 ]; then
    pip install https://github.com/RadeonOpenCompute/rbuild/archive/master.tar.gz
fi

# Update the sources to the latest
cd AMDMIGraphX
git pull

# Build new copies
rbuild build -d depend

# Run the tests to make sure all is OK
cd build && make check
