#!/bin/bash

AWK_SCRIPT=' $0 !~ /^".*/ && length($4) {
	if (!($1 in LISTED)) {
		print($4);
		LISTED[$1] = 1
	}
} '

if [[ -n "$1" ]]; then
	DIR="$1"
else
	DIR="."
fi

SIZE_CHILDREN=$(ls -ARQgoi "$DIR" | awk "$AWK_SCRIPT")
SIZE=$(ls -AQdgoi "$DIR" | awk "$AWK_SCRIPT")

for val in $SIZE_CHILDREN; do
  SIZE=$(( $SIZE + $val ));
done

echo $SIZE
