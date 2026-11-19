#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file.md>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found."
    exit 1
fi

# Extract links using grep
links=$(grep -oE '\[.*\]\((http|https|/|\.|\.\.).*\)' "$FILE" | sed -E 's/.*\]\((.*)\)/\1/')

for link in $links; do
    if [[ $link =~ ^http ]]; then
        status=$(curl -s -o /dev/null -w "%{http_code}" --head "$link" || echo "000")
        if [[ "$status" == "200" ]]; then
            echo "[OK] $link"
        else
            echo "[FAIL] $link ($status)"
        fi
    else
        if [ -f "$link" ]; then
            echo "[OK] $link"
        else
            echo "[FAIL] $link (file not found)"
        fi
    fi
done