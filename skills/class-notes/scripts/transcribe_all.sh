#!/usr/bin/env bash
# Paced transcription: 16-min batches, low priority, 60 s pause between batches
# (the user dislikes fan noise). Run in background. Skips batches already done.
# Usage: transcribe_all.sh <work_dir>
# Then: transcript is <work_dir>/tr/t1.txt ... tN.txt and <work_dir>/tr/compact.txt
set -uo pipefail
W="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$W/video.mp4" | cut -d. -f1)
i=1
for st in $(seq 0 960 "$D"); do
  en=$((st + 960)); [ "$en" -gt "$D" ] && en=$D
  if [ ! -s "$W/tr/t$i.txt" ]; then
    nice -n 15 python3 "$DIR/transcribe.py" "$W/video.mp4" "$st" "$en" "$W/tr/t$i" >/dev/null 2>&1 \
      && echo "batch $i ok" || echo "batch $i FAILED"
    sleep 60
  fi
  i=$((i + 1))
done
# Compact: join short Whisper segments into ~25-line paragraphs, keeping the first timestamp.
ls "$W"/tr/t*.txt | sort -V | xargs cat \
  | awk '{ts=$1; $1=""; buf=buf $0} NR%25==0 {print ts buf; buf=""} END{print ts buf}' > "$W/tr/compact.txt"
echo "DONE $(wc -c < "$W/tr/compact.txt") bytes"
