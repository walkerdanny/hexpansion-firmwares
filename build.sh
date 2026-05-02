#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_ROOT/build"

mkdir -p "$BUILD_DIR"

for parent in "$REPO_ROOT"/0x*/; do
    parent_name="$(basename "$parent")"
    for child in "$parent"0x*/; do
        [ -d "$child" ] || continue
        child_name="$(basename "$child")"
        archive_name="firmware_${parent_name}_${child_name}.tar.gz"
        if [ -z "$(ls -A "$child")" ]; then
            echo "Skipping $parent_name/$child_name (empty)"
            continue
        fi
        echo "Packing $parent_name/$child_name -> build/$archive_name"
        (cd "$child" && tar czf "$BUILD_DIR/$archive_name" --exclude=eeprom.json --exclude=README.md .)
        if [ -f "$child/eeprom.json" ]; then
            cp "$child/eeprom.json" "$BUILD_DIR/firmware_${parent_name}_${child_name}.json"
        fi
    done
done

find "$BUILD_DIR" -maxdepth 1 -type f -empty -delete
