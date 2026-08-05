#!/usr/bin/env bash

# Shell script to rename all .md files in the _posts directory
# Format: {date}-{title}.md
# - date extracted from 'date:' frontmatter field
# - title extracted from 'title:' frontmatter field with spaces & symbols replaced by '-'

POSTS_DIR="${1:-_posts}"

if [ ! -d "$POSTS_DIR" ]; then
  echo "Error: Directory '$POSTS_DIR' does not exist."
  exit 1
fi

count=0

for file in "$POSTS_DIR"/*.md; do
  # Skip if no .md files found
  [ -e "$file" ] || continue

  # Extract date value (e.g. 2026-12-1 or 2026-12-01)
  date_val=$(grep -m 1 -E '^[[:space:]]*date:' "$file" \
    | sed -E 's/^[[:space:]]*date:[[:space:]]*//; s/^["'\''"]//; s/["'\''"]$//' \
    | awk '{print $1}')

  # Extract title value without relying on line number
  title_val=$(grep -m 1 -E '^[[:space:]]*title:' "$file" \
    | sed -E 's/^[[:space:]]*title:[[:space:]]*//; s/^["'\''"](.*)["'\''"]$/\1/; s/^["'\''"]//; s/["'\''"]$//')

  if [ -z "$date_val" ] || [ -z "$title_val" ]; then
    echo "Skipping $(basename "$file"): missing date or title field"
    continue
  fi

  # Convert title: replace spaces and all non-alphanumeric characters with '-'
  # Convert uppercase to lowercase, collapse consecutive hyphens, and trim leading/trailing hyphens
  slug_title=$(echo "$title_val" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g' \
    | sed -E 's/^-+|-+$//g')

  new_filename="${date_val}-${slug_title}.md"
  new_filepath="${POSTS_DIR}/${new_filename}"

  if [ "$file" != "$new_filepath" ]; then
    if [ -e "$new_filepath" ]; then
      echo "Warning: Target $new_filename already exists! Skipping $(basename "$file")."
    else
      echo "Renaming: $(basename "$file") -> $new_filename"
      mv "$file" "$new_filepath"
      ((count++))
    fi
  else
    echo "Unchanged: $(basename "$file")"
  fi
done

echo ""
echo "Done! Renamed $count file(s)."
