#!/bin/bash

mx=${1-320}
my=${2-256}
outfile=${3-random}
head -c "$((3*mx*my))" /dev/urandom | convert -depth 8 -size "${mx}x${my}" RGB:- "${outfile}".png
