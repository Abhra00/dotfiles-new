#!/usr/bin/env bash

cd "$(pwd)" || exit 1
echo "Enter theme name :->"
read -r themeName

i=1

# Step 1: Rename to temp names to avoid collisions
find . -maxdepth 1 -type f ! -name '.tmp_rename_*' | while read -r f; do
    ext="${f##*.}"
    mv -- "$f" ".tmp_rename_$i.$ext"
    ((i++))
done

# Step 2: Rename temp files to final numbered names
i=1
for f in .tmp_rename_*; do
    [ -f "$f" ] || continue
    ext="${f##*.}"
    mv -- "$f" "$themeName-$i.$ext"
    ((i++))
done
