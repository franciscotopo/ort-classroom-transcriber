#!/usr/bin/env bash
# Tile the 2-second frames nearest to given timestamps (seconds) into one 4x2 sheet,
# to verify that the transcript matches what was on screen.
# Usage: frames_at.sh <work_dir> <t1> <t2> ... (up to 8)
set -euo pipefail
W="$1"; shift
: > "$W/cmp.txt"
for t in "$@"; do printf "file '%s/f2s/f_%05d.jpg'\n" "$W" $((t / 2 + 1)) >> "$W/cmp.txt"; done
nice ffmpeg -v error -y -f concat -safe 0 -i "$W/cmp.txt" -vf "scale=640:-2,tile=4x2" -frames:v 1 -q:v 4 "$W/cmp.jpg"
echo "$W/cmp.jpg"
