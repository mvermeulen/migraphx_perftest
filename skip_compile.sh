#!/bin/bash
awk 'NR == 1, /Running performance report .../ { next } { print }' $1
