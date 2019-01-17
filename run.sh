#!/bin/bash
#
# run.sh - script for running basic MIGraphX performance tests.
#
# Parameters - these can be modified by passing in as ENVIRONMENT variables.
#              Default values are found to right of the := variable.
PERF_ONNX=${PERF_ONNX:="./bin/perf_onnx"}
MIGRAPHX_LIBS=${MIGRAPHX_LIBS:="./lib"}
ONNX_DIR=${ONNX_DIR:="./onnx"}
OUTPUT_DIR=${OUTPUT_DIR:="./output"}
TESTLIST=${TESTLIST:=`ls onnx`}
TIMESTAMP=${TIMESTAMP:=`date '+%Y-%m-%d-%H:%M:%S'`}

export LD_LIBRARY_PATH=${MIGRAPHX_LIBS}

for test in ${TESTLIST}
do
    testname=`basename $test .onnx`
    testout=${OUTPUT_DIR}/$testname-${TIMESTAMP}.out
    testerr=${OUTPUT_DIR}/$testname-${TIMESTAMP}.err

    echo $TIMESTAMP " running " $testname
    ${PERF_ONNX} ${ONNX_DIR}/$test 1>$testout 2>$testerr
    if grep "Total timex" $testout > result; then
	echo PASS `cat result`
    else
	echo FAIL `cat $testerr`
    fi
done


