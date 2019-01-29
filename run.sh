#!/bin/bash
#
# run.sh - script for running basic MIGraphX performance tests.
#
# Parameters - these can be modified by passing in as ENVIRONMENT variables.
#              Default values are found to right of the := variable.
PERF_ONNX=${PERF_ONNX:="./bin/perf_onnx"}
PERF_ONNX2=${PERF_ONNX:="./bin/perf_onnx2"}
MIGRAPHX_LIBS=${MIGRAPHX_LIBS:="/opt/rocm/lib"}
ONNX_DIR=${ONNX_DIR:="./onnx"}
OUTPUT_DIR=${OUTPUT_DIR:="./output"}
TESTLIST=${TESTLIST:=`ls onnx`}
TIMESTAMP=${TIMESTAMP:=`date '+%Y-%m-%d-%H:%M:%S'`}
RUNTUNE=${RUNTUNE:=0}
RUNPROFILE=${RUNPROFILE:=0}
COMBINE_STDERROUT=${COMBINE_STDERROUT:=0}

if [ ! -f ${MIGRAPHX_LIBS}/libmigraphx.so ]; then
    echo FAIL migraphx library not found
    exit 1
fi

tunecmd=""
if [ $RUNTUNE != 0 ]; then
    tunecmd="MIOPEN_FIND_ENFORCE=3"
fi

execnt=""
profilecmd=""
if [ $RUNPROFILE == 2 ]; then
    profilecmd="HCC_PROFILE=2 MIGRAPHX_TRACE_EVAL=1"
    execnt=1
    COMBINE_STDERROUT=1
elif [ $RUNPROFILE != 0 ]; then
    profilecmd="HCC_PROFILE=2"
    COMBINE_STDERROUT=1    
fi

export LD_LIBRARY_PATH=${MIGRAPHX_LIBS}

for test in ${TESTLIST}
do
    testname=`basename $test .onnx`
    batchsize=`echo $testname | perl -ne 'print $1 if /.*i([0-9]+).*/'`
    testout=${OUTPUT_DIR}/$testname-${TIMESTAMP}.out
    testerr=${OUTPUT_DIR}/$testname-${TIMESTAMP}.err

    echo $TIMESTAMP " running " $testname
    if [ $RUNTUNE != 0 -o $RUNPROFILE != 0 ]; then
	if [ $COMBINE_STDERROUT != 0 ]; then
	    env $tunecmd $profilecmd ${PERF_ONNX2} ${ONNX_DIR}/$test $execnt >$testout 2>&1
	else
	    env $tunecmd $profilecmd ${PERF_ONNX2} ${ONNX_DIR}/$test 1>$testout 2>$testerr	    
	fi
    else
	if [ $COMBINE_STDERROUT != 0 ]; then
	    ${PERF_ONNX} ${ONNX_DIR}/$test >$testout 2>&1
	else
	    ${PERF_ONNX} ${ONNX_DIR}/$test 1>$testout 2>$testerr
	fi
    fi
    if grep "Rate: " $testout > lastresult; then
	rate=`awk -F'[ /]' '{ print $2 }' lastresult`
	imagepersec=`echo $rate \* $batchsize | bc`
	echo "PASS " $imagepersec
	if [ $RUNPROFILE != 0 ]; then
	    rpt $testout > ${OUTPUT_DIR}/$testname-${TIMESTAMP}.rpt
	    ./skip_compile.sh $testout > ${testout}2
	    rpt ${testout}2 > ${OUTPUT_DIR}/$testname-${TIMESTAMP}.rpt2
	fi
    else
	echo FAIL `cat $testerr`
    fi
done
