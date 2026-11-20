#!/usr/bin/env bash
# Download a class and extract screen frames.
# Usage: prepare.sh <dd-mm-yyyy|video_id>
# Output: ~/.class-notes/work/<course>/<key>/{video.mp4, f2s/, sheets/}
set -euo pipefail
KEY="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"
COURSE="${CLASS_NOTES_COURSE:-$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.class-notes/config.json')))['default_course'])")}"
W="$HOME/.class-notes/work/$COURSE/$KEY"
mkdir -p "$W/f2s" "$W/sheets" "$W/tr"
PY="$(dirname "$(readlink -f "$(which yt-dlp)")")/python"

[ -s "$W/video.mp4" ] || "$PY" "$DIR/vimeo_album.py" download "$KEY" "$W/video.mp4"

# One frame every 2 s (screen changes), then one per minute tiled 2x2 for a quick overview.
if [ -z "$(ls -A "$W/f2s")" ]; then
  nice -n 15 ffmpeg -v error -i "$W/video.mp4" -vf "fps=0.5,scale=1280:-2" -q:v 4 "$W/f2s/f_%05d.jpg"
fi
ls "$W/f2s" | awk 'NR%30==1' | sed "s|^|file '$W/f2s/|;s|$|'|" > "$W/min.txt"
nice -n 15 ffmpeg -v error -y -f concat -safe 0 -i "$W/min.txt" -vf "scale=800:-2,tile=2x2" -fps_mode passthrough -q:v 4 "$W/sheets/sh_%02d.jpg"
echo "dir=$W sheets=$(ls "$W/sheets" | wc -l | tr -d ' ') duration_s=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$W/video.mp4" | cut -d. -f1)"
