#!/usr/bin/env bash

if [[ -n "$1" ]]; then
	OUT="$1"
else
	echo "Specify output file name"
	exit 1
fi

extensions="${@:2}"

if [[ -z "$extensions" ]]; then
	echo "Specify code files extensions" >&2
	exit 1
fi

if [[ -d "$OUT" ]]; then
	echo "Directory $OUT already exists." >&2
	exit 1
fi

mkdir "$OUT"

if [[ ! -d "$OUT" ]]; then
	echo "Cannot create directory" >&2
	exit 1
fi



BackupFile() {
	local folder=$(dirname "$1")

	local backup_folder="$OUT$folder"
	local backup_path="$OUT$1"
	mkdir -p "$backup_folder"

	cp "$1" "$backup_path"
}


declare -A handled

Process() {
	local file="$1" # absolute path, no symlinks

	if [[ -n ${handled["$file"]} ]]; then
		return 0
	fi
	handled["$file"]=1

	if [[ -d "$file" ]]; then
		Lookup "$file"
	elif [[ -f "$file" ]]; then
		
		for ext in $extensions; do
			if [[ "$file" == *"$ext" ]]; then
				BackupFile "$file"
			fi
		done

	fi
}

Lookup() {
	local name
	while read -r name; do
		local full_name="$1/$name"
		if [[ -h "$full_name" ]]; then
			full_name=$(readlink -fn "$full_name")
		fi

		echo "$full_name"
		Process "$full_name"
	done < <(ls --quoting-style=literal -1A "$1")
}

Lookup ~

echo "Packing..."
out_base=$(basename "$OUT")
out_prefix=$(dirname "$OUT")
tar -C "$out_prefix" -cf "${OUT}.tar" "$out_base"
