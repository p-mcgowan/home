#!/bin/bash

x1=$1
y1=$2
x2=$3
y2=$4

x3=$5
y3=$6
x4=$7
y4=$8

if [ $# -ne 8 ]; then
  echo usage: $(basename $0) x1 y1 x2 y2 x3 y3 x4 y4
  echo calculates the intersection of 2 lines defined by 4 points
  exit 1
fi

docalc() {
  echo "$1" | bc -l
}

m1=$(docalc "($y2 - $y1) / ($x2 - $x1)")
m2=$(docalc "($y4 - $y3) / ($x4 - $x3)")
b1=$(docalc  "$y1 - $m1 * $x1")
b2=$(docalc  "$y3 - $m2 * $x3")
X=$(docalc "($b2 - $b1)/($m1 - $m2)")
Y=$(docalc "$m2*$X + $b2")

echo "$X $Y" |sed 's/00\+\b/0/g'
