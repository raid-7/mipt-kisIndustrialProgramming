#!/bin/bash

AWK_SCRIPT='$0 !~ /^".*/ && length($3) { sum += $3 } END { print(sum) }'

SIZE_CHILDREN=$(ls -ARQgo | awk "$AWK_SCRIPT")
SIZE_SELF=$(ls -AQdgo | awk "$AWK_SCRIPT")

echo $(( $SIZE_CHILDREN + $SIZE_SELF ))
