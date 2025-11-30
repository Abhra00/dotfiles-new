#!/usr/bin/env bash

OLD="$1"
NEW="$2"

for img in *.$OLD; do
    [ -e "$img" ] || continue  # skip if no files match
    BASE_NAME="${img%.*}"
    magick "$img" "$BASE_NAME.$NEW"
    echo "Processing: $img -> $BASE_NAME.$NEW"
done

