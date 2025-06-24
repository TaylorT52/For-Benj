#!/bin/sh

#  photos.sh
#  For-Benj
#
#  Created by Taylor Tam on 6/23/25.
#  
# rename_photos.sh  – run from the directory that contains  photos/
i=1
find photos -type f | sort |
while read -r f; do
  ext="${f##*.}"                              # original extension
  dir=$(dirname "$f")
  lc_ext=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')  # ↓ lower-case
  new="${dir}/Photo_${i}.${lc_ext}"

  if [ -e "$new" ]; then
    echo "⚠️  $new already exists – skipped"
  else
    mv "$f" "$new"
    echo "✔︎  $f  ➜  $new"
    i=$((i + 1))
  fi
done

