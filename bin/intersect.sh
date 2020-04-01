#!/bin/bash

x1=$1
y1=$2
x2=$3
y2=$4

x3=$5
y3=$6
x4=$7
y4=$8

docalc() {
  echo $(calc -- "$1" |xargs |sed 's/^~//g')
}

m1=$(docalc "($y2 - $y1) / ($x2 - $x1)")
m2=$(docalc "($y4 - $y3) / ($x4 - $x3)")
b1=$(docalc  "$y1 - $m1 * $x1")
b2=$(docalc  "$y3 - $m2 * $x3")
X=$(docalc "($b2 - $b1)/($m1 - $m2)")
Y=$(docalc "$m2*$X + $b2")

echo "$X $Y"
