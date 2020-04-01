awk '{if (!seen[$0]) print $0; seen[$0]++}'
