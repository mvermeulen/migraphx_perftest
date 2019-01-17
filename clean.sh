#!/bin/bash
#
# clean.sh - cleanup temporary test artifacts
OUTPUT_DIR=${OUTPUT_DIR:="./output"}
rm $OUTPUT_DIR/* lastresult
